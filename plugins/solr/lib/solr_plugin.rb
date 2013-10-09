class SolrPlugin < Noosfero::Plugin; end;

require_dependency 'solr_plugin/search_helper'

class SolrPlugin < Noosfero::Plugin

  include SolrPlugin::SearchHelper

  def self.plugin_name
    "Solr"
  end

  def self.plugin_description
    _("Uses Solr as search engine.")
  end

  def stylesheet?
    true
  end

  def find_by_contents(asset, scope, query, paginate_options={}, options={})
    klass = asset_class(asset)
    category = options.delete(:category)
    filter = options.delete(:filter)

    return if empty_query?(query, category) && klass != Product

    solr_options = solr_options(class_asset(klass), category)
    solr_options[:filter_queries] ||= []
    solr_options[:filter_queries] += scopes_to_solr_filters scope, klass

    solr_options.merge!(products_options(user)) if klass == Product && empty_query?(query, category)

    scope.find_by_contents query, paginate_options, solr_options.merge(options)
  end

  protected

  def scopes_to_solr_filters scope, klass = nil
    filter_queries = []
    klass ||= scope.base_class
    solr_fields = klass.configuration[:solr_fields].keys
    scopes_applied = scope.scopes_applied.dup rescue [] #rescue association and class direct filtering

    scope.current_scoped_methods[:create].each do |attr, value|
      next unless solr_fields.include? attr.to_sym

      # if the filter is present here, then prefer it
      scopes_applied.reject!{ |name| name == attr.to_sym }

      filter_queries << "#{attr}:#{value}"
    end

    scopes_applied.each do |name|
      has_value = name === Hash
      if has_value
        name, args = name.keys.first, name.values.first
        value = args.first
      end

      related_field = nil
      related_field = name if solr_fields.include? name
      related_field = "solr_plugin_#{name}" if solr_fields.include? :"solr_plugin_#{name}"

      if has_value
        if related_field
          filter_queries << "#{related_field}:#{value}"
        else
          filter_queries << klass.send("solr_filter_#{name}", *args)
        end
      else
        raise "Undeclared solr field for scope #{name}" if related_field.nil?
        filter_queries << "#{related_field}:true"
      end
    end

    filter_queries
  end

  def method_missing method, *args, &block
    if self.context.respond_to? method
      self.context.send method, *args, &block
    else
      super method, *args, &block
    end
  end

end
