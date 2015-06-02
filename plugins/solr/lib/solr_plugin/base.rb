# FIXME: module not being loaded
require 'solr_plugin'

class SolrPlugin::Base < Noosfero::Plugin

  def stylesheet?
    true
  end

  def js_files
    ['solr'].map{ |j| "javascripts/#{j}" }
  end

  def catalog_find_by_contents asset, scope, query, paginate_options={}, options={}
  	klass = Product

  	# Search for products -> considers the query and the filters:
    params[:facet] = {}
    params[:facet][:solr_plugin_f_category] = params[:category] if params[:category].present?
    params[:facet][:solr_plugin_f_qualifier] = params[:qualifier] if params[:qualifier].present?
    solr_options = build_solr_options asset, klass, scope, nil
    solr_options[:all_facets] = false

    order = params[:order]
    order = if order.blank? then :relevance else order.to_sym end
    if sort = SortOptions[:catalog][order] rescue nil
      solr_options.merge! (if query.blank? and sort[:empty_solr_opts] then sort[:empty_solr_opts] else sort[:solr_opts] end)
    end
    result = scope.find_by_contents query, paginate_options, solr_options

    # Preparing the filters -> they must always contain all filters for the specific query:
    solr_options = build_solr_options asset, klass, scope, nil, ignore_filters: true
    solr_options[:all_facets] = false
    query = "" if result[:results].total_entries == 0
    result_facets = scope.find_by_contents query, paginate_options, solr_options
    facets = result_facets[:facets]['facet_fields'] || {}

    result[:categories] = facets['solr_plugin_f_category_facet'].to_a.map{ |name,count| ["#{name} (#{count})", name] }
    result[:categories].sort!{ |a,b| a[0] <=> b[0] }
    result[:qualifiers] = facets['solr_plugin_f_qualifier_facet'].to_a
    result[:qualifiers] = Product.solr_plugin_f_qualifier_proc nil, result[:qualifiers]
    result[:qualifiers].map!{ |id, name, count| ["#{name} (#{count})", id] }
    result[:qualifiers].sort!{ |a,b| a[0] <=> b[0] }

    result
  end

  def find_by_contents asset, scope, query, paginate_options={}, options={}
  	# The query in the catalog top bar is too specific and therefore must be treated differently
    return catalog_find_by_contents asset, scope, query, paginate_options, options if asset == :catalog

    category = options.delete :category
    filter = options.delete(:filter).to_s.to_sym
  	klass = asset_class asset

  	solr_options = build_solr_options asset, klass, scope, category
    solr_options.merge! sort_options asset, klass, filter
    solr_options.merge! options

    scope.find_by_contents query, paginate_options, solr_options
  rescue Exception => e
    # solr seaches depends on a constant translation of named scopes SQL's into solr filtered fields
    # so while we can't keep up it core changes, report the error and use default like search
    if Rails.env.production?
      ExceptionNotifier.notify_exception e,
        env: context.request.env, data: {message: "Solr search failed"}
      super
    else
      raise
    end
  end

  def autocomplete asset, scope, query, paginate_options={}, options={}
    solr_options = {}
    solr_options.merge! paginate_options

    case asset
    when :catalog
      klass = Product
      solr_options[:query_fields] = %w[solr_plugin_ac_name^100 solr_plugin_ac_category^90 solr_plugin_ac_supplier^80]
      solr_options[:highlight] = {fields: 'name'}
      solr_options[:filter_queries] = scopes_to_solr_options scope, klass, options
    end
    solr_options[:default_field] = 'ngramText'

    result = {results: scope.find_by_solr(query, solr_options).results}
    result
  end

  def search_order asset
    case asset
    when :catalog
      {
        select_options: SortOptions[:catalog].map do |key, options|
          option = options[:option]
          [_(option[0]), option[1]]
        end,
      }
    end
  end

  def search_pre_contents
    lambda do
      render 'solr_plugin/search/search_pre_contents'
    end
  end

  def search_post_contents
    lambda do
      render 'solr_plugin/search/search_post_contents'
    end
  end

  protected

  include SolrPlugin::SearchHelper

  def build_solr_options asset, klass, scope, category, options = {}
    solr_options = {}

    selected_facets = if options[:ignore_filters] then {} else params[:facet] end
    if klass.respond_to? :facets
      solr_options.merge! klass.facets_find_options selected_facets
      solr_options[:all_facets] = true
    end

    solr_options[:filter_queries] ||= []
    solr_options[:filter_queries] += solr_filters_queries asset, environment
    solr_options[:filter_queries] << klass.facet_category_query.call(category) if category
    solr_options[:filter_queries] += scopes_to_solr_options scope, klass, options

    solr_options[:boost_functions] ||= []
    params[:order_by] = nil if params[:order_by] == 'none'
    if params[:order_by]
      order = SortOptions[asset][params[:order_by].to_sym]
      raise "Unknown order by" if order.nil?
      order[:solr_opts].each do |opt, value|
        solr_options[opt] = value.is_a?(Proc) ? instance_eval(&value) : value
      end
    end

    solr_options
  end

  def scopes_to_solr_options scope, klass = nil, options = {}
    filter_queries = []
    klass ||= scope.base_class
    solr_fields = klass.configuration[:solr_fields].keys rescue []
    scopes_applied = scope.scopes_applied.dup rescue [] #rescue association and class direct filtering

    scope.scope_attributes.each do |attr, value|
      next if attr == 'type'
      raise "Non-indexed attribute '#{attr}' speficied in scope_attributes" unless solr_fields.include? attr.to_sym

      # if the filter is present here, then prefer it
      scopes_applied.reject!{ |name| name == attr.to_sym }

      filter_queries << "#{attr}:#{value}"
    end

    scopes_applied.each do |name|
      #next if name.to_s == options[:filter].to_s

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
        if related_field
          filter_queries << "#{related_field}:true"
        end
      end
    end

    filter_queries
  end

  def sort_options asset, klass, filter
    options = SolrPlugin::SearchHelper::SortOptions[asset]
    options[filter][:solr_opts] rescue {}
  end

end

