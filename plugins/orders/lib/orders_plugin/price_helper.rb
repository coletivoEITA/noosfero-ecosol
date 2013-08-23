module OrdersPlugin::PriceHelper

  protected

  def price_span price, options = {}
    return nil if price.blank?
    content_tag 'span',
      content_tag('span', price, :class => 'price-value'),
      options
  end

  def price_with_unit_span price, unit, detail=nil
    return nil if price.blank?
    detail ||= ''
    detail = " (#{detail})" unless detail.blank?
    I18n.t('orders_plugin.lib.price_helper.price_unit') % {:price => price_span(price), :unit => content_tag('span', I18n.t('orders_plugin.lib.price_helper./') + unit.singular + detail, :class => 'price-unit')}
  end

end
