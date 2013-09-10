# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
require_dependency 'orders_plugin/date_helper'

module OrdersCyclePlugin::DisplayHelper

  protected

  include ::ActionView::Helpers::JavaScriptHelper # we want the original button_to_function!
  include OrdersPlugin::PriceHelper
  include OrdersPlugin::DisplayHelper
  include OrdersPlugin::DateHelper

  def edit_arrow anchor, toggle = true, options = {}
    options[:class] ||= ''
    options[:onclick] ||= ''
    options[:class] += ' actions-circle toggle-edit'
    options[:onclick] = "r = sortable_table.edit_arrow_toggle(this); #{options[:onclick]}; return r;" if toggle

    content_tag 'div',
      link_to(content_tag('div', '_', :class => 'action-hide') + content_tag('div', '+', :class => 'action-show'), anchor, options),
      :class => 'box-field actions'
  end

  def excerpt_ending text, length
    return nil if text.blank?
    excerpt text, text.first(3), length
  end

end
