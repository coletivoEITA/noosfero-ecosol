# FIXME without this the User#save crashes
require 'noosfero/multi_tenancy'

module SolrPlugin

  module ActsAsSearchable

    module ClassMethods
      ACTS_AS_SEARCHABLE_ENABLED = true unless defined? ACTS_AS_SEARCHABLE_ENABLED

      def acts_as_searchable(options = {})
        return if !ACTS_AS_SEARCHABLE_ENABLED

        if options[:fields]
          options[:fields] << {schema_name: :string}
        else
          options[:additional_fields] ||= []
          options[:additional_fields] << {schema_name: :string}
        end

        acts_as_solr options
        extend FindByContents
        send :include, InstanceMethods
      end

      module InstanceMethods
        def schema_name
          self.class.schema_name
        end

        # replace solr_id from acts_as_solr_reloaded/lib/acts_as_solr/instance_methods.rb
        # to include schema_name
        def solr_id
           id = "#{self.class.name}:#{record_id(self)}"
           id.insert 0, "#{schema_name}:" unless schema_name.blank?
           id
        end
      end

      module FindByContents

        def schema_name
          (Noosfero::MultiTenancy.on? and ActiveRecord::Base.postgresql?) ? ActiveRecord::Base.connection.schema_search_path : ''
        end

        def find_by_contents query, pg_options = {}, options = {}, db_options = {}
          options[:sql_options] = db_options

          pg_options[:page] ||= 1
          pg_options[:per_page] ||= 20
          page = options[:page] = pg_options[:page].to_i
          per_page = options[:per_page] = pg_options[:per_page].to_i
          if options[:extra_limit]
            options[:per_page] = options.delete :extra_limit
            options[:sql_options][:limit] = per_page
          end

          options[:scores] ||= true
          options[:filter_queries] ||= []
          options[:filter_queries] << "schema_name:\"#{schema_name}\"" unless schema_name.blank?
          options[:query_fields] = options.delete :fields if options[:fields].present?
          options[:facets] ||= {}
          all_facets_enabled = options.delete :all_facets
          results = []
          facets = all_facets = {}

          solr_result = find_by_solr query, options
          if all_facets_enabled
            options[:facets][:browse] = nil
            all_facets = find_by_solr(query, options.merge(per_page: 0, results_format: :none)).facets
          end

          facets = solr_result.facets if options.include? :facets and solr_result.present?
          # solr_results has pagination options
          results = solr_result

          {results: results, facets: facets, all_facets: all_facets}
        end
      end
    end
  end

  ActiveRecord::Base.send :extend, ActsAsSearchable::ClassMethods
end
