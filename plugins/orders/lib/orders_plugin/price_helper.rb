module OrdersPlugin::PriceHelper

  protected

  def price_with_unit_span price, unit, detail=nil
    return nil if price.blank?
    detail ||= ''
    detail = " (#{detail})" unless detail.blank?
    I18n.t('orders_plugin.lib.price_helper.price_unit') % {:price => price_span(price), :unit => content_tag('span', unit.singular + detail.to_s, :class => 'price-unit')}
  end

end
