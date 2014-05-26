module OrdersPlugin::PriceHelper

  protected

  def price_with_unit_span price, unit, detail=nil, options = {}
    return nil if price.blank?
    detail ||= ''
    detail = " (#{detail})" unless detail.blank?
    # the scoped class is styled globally
    options[:class] = "orders-price-with-unit price-with-unit #{options[:class]}"
    text = I18n.t('orders_plugin.lib.price_helper.price_unit') % {
      :price => price_span(price),
      :unit => content_tag('div', (unit.singular rescue '') + detail, :class => 'price-unit'),
    }

    content_tag 'div', text, options.merge(:title => text)
  end

end
