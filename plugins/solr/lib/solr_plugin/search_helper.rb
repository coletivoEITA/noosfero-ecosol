module SolrPlugin::SearchHelper

  protected

  LIST_SEARCH_LIMIT = 20
  DistFilt = 200
  DistBoost = 50

  SortOptions = {
    catalog: {
      relevance: {option: ['Relevance', ''], solr_opts: {},
                  empty_solr_opts: {sort: 'solr_plugin_available_sortable desc, solr_plugin_highlighted_sortable desc, solr_plugin_name_sortable asc'}},
      name: {option: ['Name', 'name'], solr_opts: {sort: 'solr_plugin_available_sortable desc, solr_plugin_name_sortable asc'}},
      price: {option: ['Lowest price', 'price'], solr_opts: {sort: 'solr_plugin_available_sortable desc, solr_plugin_price_sortable asc'}},
      newest: {option: ['Newest', 'newest'], solr_opts: {sort: 'solr_plugin_available_sortable desc, created_at desc'}},
      updated: {option: ['Last updated', 'updated'], solr_opts: {sort: 'solr_plugin_available_sortable desc, updated_at desc'}},
    },
    products: {
      none: {label: _('Relevance')},
      more_recent: {label: c_('More recent'), solr_opts: {sort: 'created_at desc, score desc'}},
      #more_recent: {label: c_('More recent'), solr_opts: {boost_functions: ['recip(ms(NOW/HOUR,updated_at),1.3e-10,1,1)']}},
      name: {label: _('Name'), solr_opts: {sort: 'solr_plugin_name_sortable asc'}},
      closest: {label: _('Closest to me'), if: proc{ logged_in? && (profile=current_user.person).lat && profile.lng },
        solr_opts: {sort: "geodist() asc",
          latitude: proc{ current_user.person.lat }, longitude: proc{ current_user.person.lng }}},
    },
    events: {
      none: {label: _('Relevance')},
      name: {label: _('Name'), solr_opts: {sort: 'solr_plugin_name_sortable asc'}},
      more_recent: {label: c_('More recent'), solr_opts: {sort: 'created_at desc, score desc'}},
    },
    articles: {
      none: {label: _('Relevance')},
      name: {label: _('Name'), solr_opts: {sort: 'solr_plugin_name_sortable asc'}},
      more_recent: {label: c_('More recent'), solr_opts: {sort: 'created_at desc, score desc'}},
    },
    enterprises: {
      none: {label: _('Relevance')},
      name: {label: _('Name'), solr_opts: {sort: 'solr_plugin_name_sortable asc'}},
      more_recent: {label: c_('More recent'), solr_opts: {sort: 'created_at desc, score desc'}},
    },
    people: {
      none: {label: _('Relevance')},
      name: {label: _('Name'), solr_opts: {sort: 'solr_plugin_name_sortable asc'}},
      more_recent: {label: c_('More recent'), solr_opts: {sort: 'created_at desc, score desc'}},
    },
    communities: {
      none: {label: _('Relevance')},
      name: {label: _('Name'), solr_opts: {sort: 'solr_plugin_name_sortable asc'}},
      more_recent: {label: c_('More recent'), solr_opts: {sort: 'created_at desc, score desc'}},
    },
  }

  TotalFound = {
    products: N_("%s products and/or services found"),
    articles: N_("%s contents found"),
    events: N_("%s events found"),
    people: N_("%s people found"),
    enterprises: N_("%s enterprises found"),
    communities: N_("%s communities found"),
  }

  def empty_search?
    @query.blank? and params[:facet].blank? and @category.blank?
  end
  def empty_query?(query, category)
    category.nil? && query.blank?
  end

  def solr_filters_queries asset
    case asset
    when :products
      ['solr_plugin_public:true', 'enabled:true']
    when :catalog
      []
    when :events
      []
    else
      ['solr_plugin_public:true']
    end
  end

  def asset_class(asset)
    asset.to_s.singularize.camelize.constantize
  rescue
    asset.to_s.singularize.camelize.gsub('Plugin', 'Plugin::').constantize
  end

  def order_by(asset)
    options = SortOptions[asset].map do |name, options|
      next if options[:if] && !instance_eval(&options[:if])
      [_(options[:label]), name.to_s]
    end.compact

    content_tag('div',
      content_tag('label',_('Sort results by ') + ':', class: 'col-lg-4 col-md-4 col-sm-4 col-xs-6 control-label form-control-static') +
      content_tag('div',select_tag(asset.to_s + '[order]', options_for_select(options, params[:order_by] || 'none'),
        {onchange: "window.location = jQuery.param.querystring(window.location.href, { 'order_by' : this.options[this.selectedIndex].value})"}
      ),class: 'col-lg-8 col-md-8 col-sm-8 col-xs-6'),
      class: "row"
    )
 end

  def label_total_found asset, total_found
    content_tag('span', _(TotalFound[asset]) % number_to_human(total_found),
      class: "total-pages-found") if TotalFound[asset]
  end

  def load_facets
    @facets = @searches[@asset][:facets]
    @all_facets = @searches[@asset][:all_facets]
  end

  def facets_menu asset
    @asset_class = asset_class asset
    load_facets
    render 'solr_plugin/search/facets_menu'
  end

  def facets_unselect_menu(asset)
    @asset_class = asset_class asset
    render 'solr_plugin/search/facets_unselect_menu'
  end

  def facet_selecteds_html_for environment, klass, params
    def name_with_extra(klass, facet, value)
      name = klass.facet_result_name(facet, [[value, 0]])
      return unless name
      name = name[0].to_s + name[1].to_s if name.is_a? Array
      name
    end

    ret = []
    params = params.dup
    params[:facet].each do |id, value|
      next if value.blank?
      facet = klass.facet_by_id id.to_sym
      next if facet.blank?
      if value.kind_of?(Hash)
        label_hash = facet[:label].call(environment)
        value.each do |label_id, value|
          facet[:label_id] = label_id
          facet[:label] = label_hash[label_id]
          value.to_a.each do |value|
            next unless name = name_with_extra(klass, facet, value)
            ret << [facet[:label], name,
              params.merge(:facet => params[:facet].merge(id => params[:facet][id].merge(label_id => params[:facet][id][label_id].to_a.reject{ |v| v == value })))]
          end
        end
      else
        next unless name = name_with_extra(klass, facet, value)
        ret << [klass.facet_label(facet), name,
          params.merge(:facet => params[:facet].reject{ |k,v| k == id })]
      end
    end

    ret.map do |label, name, url|
      content_tag('div', content_tag('span', label, class: 'facet-selected-label') +
        content_tag('span', name, class: 'facet-selected-name') +
        link_to('', url, class: 'icon-remove', title: 'remove facet'), class: 'facet-selected')
    end.join
  end

  def facet_link_html(facet, params, value, label, count)
    params = params ? params.dup : {}
    has_extra = label.kind_of?(Array)
    link_label = has_extra ? label[0] : label
    id = facet[:solr_field].to_s
    params[:facet] ||= {}
    params[:facet][id] ||= {}
    params[:page] = {} if params[:page]

    selected = facet[:label_id].nil? ? params[:facet][id] == value : params[:facet][id][facet[:label_id]].to_a.include?(value)

    if count > 0
      url = params.merge(facet: params[:facet].merge(
        id => if facet[:label_id].nil? then value else params[:facet][id].merge(facet[:label_id] => params[:facet][id][facet[:label_id]].to_a | [value] ) end,
      ))
    else
      # preserve others filters and change this filter
      url = params.merge(facet: params[:facet].merge(
        id => if facet[:label_id].nil? then value else { facet[:label_id] => [value] } end,
      ))
    end

    content_tag 'div', link_to(link_label, url, class: 'facet-result-link-label') +
        content_tag('span', (has_extra ? label[1] : ''), class: 'facet-result-extra-label') +
        (count > 0 ? content_tag('span', " (#{number_to_human(count)})", class: 'facet-result-count') : ''),
      class: 'facet-menu-item' + (selected ? ' facet-result-link-selected' : '')
  end

end
