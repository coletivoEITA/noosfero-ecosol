
require_dependency 'search_helper'


module SearchHelper

  def display_selector(asset, display, float = 'right')
    return super unless theme_responsive?

    display = nil if display.blank?
    display ||= asset_class(asset).default_search_display
    if [display?(asset, :map), display?(asset, :compact), display?(asset, :full)].select {|option| option}.count > 1
      compact_link = display?(asset, :compact) ? (display == 'compact' ? _('Compact') : link_to(_('Compact'), params.merge(:display => 'compact'))) : nil
      map_link = display?(asset, :map) ? (display == 'map' ? _('Map') : link_to(_('Map'), params.merge(:display => 'map'))) : nil
      full_link = display?(asset, :full) ? (display == 'full' ? _('Full') : link_to(_('Full'), params.merge(:display => 'full'))) : nil
      content_tag('div',
        content_tag('label', _('Display') + ': ', :class => 'col-lg-4 col-md-4 col-sm-4 col-xs-6 control-label form-control-static') + content_tag('div',[compact_link, map_link, full_link].compact.join(' | ').html_safe,:class => 'col-lg-8 col-md-8 col-sm-8 col-xs-6 text-left form-control-static'),
        :class => 'row'
      )
    end
  end

  def filter_selector(asset, filter, float = 'right')
    return super unless theme_responsive?

    klass = asset_class(asset)
    if klass::SEARCH_FILTERS.count > 1
      options = options_for_select(klass::SEARCH_FILTERS.map {|f| [FILTER_TRANSLATION[f], f]}, filter)
      url_params = url_for(params.merge(:filter => 'FILTER'))
      onchange = "document.location.href = '#{url_params}'.replace('FILTER', this.value)"
      select_field = select_tag(:filter, options, :onchange => onchange, :id => 'search_filter')
      content_tag('div',
        content_tag('label', _('Filter') + ':', :class => 'col-lg-4 col-md-4 col-sm-4 col-xs-6 control-label form-control-static') + content_tag('div',select_field,:class => 'col-lg-8 col-md-8 col-sm-8 col-xs-6'),
        :class => "row"
      )
    end
  end

end
