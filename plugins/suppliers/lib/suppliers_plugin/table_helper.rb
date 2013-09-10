module SuppliersPlugin::TableHelper

  protected

  def edit_arrow anchor, toggle = true, options = {}
    options[:class] ||= ''
    options[:onclick] ||= ''
    options[:class] += ' actions-circle toggle-edit'
    options[:onclick] = "r = sortable_table.edit_arrow_toggle(this); #{options[:onclick]}; return r;" if toggle

    content_tag 'div',
      link_to(content_tag('div', '_', :class => 'action-hide') + content_tag('div', '+', :class => 'action-show'), anchor, options),
      :class => 'box-field actions'
  end

end
