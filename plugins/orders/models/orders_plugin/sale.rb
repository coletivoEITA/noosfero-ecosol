class OrdersPlugin::Sale < OrdersPlugin::Order

  before_validation :fill_default_supplier_delivery
  after_save :send_notifications

  def orders_name
    'sales'
  end
  def actor_name
    :consumer
  end

  def purchase_quantity_total
    #TODO
    self.total_quantity_consumer_ordered
  end
  def purchase_price_total
    #TODO
    self.total_price_consumer_ordered
  end

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :purchase_quantity_total
  has_currency :purchase_price_total

  def supplier_delivery
    super || (self.delivery_methods.first rescue nil)
  end
  def supplier_delivery_id
    self[:supplier_delivery_id] || (self.supplier_delivery.id rescue nil)
  end

  def fill_default_supplier_delivery
    self[:supplier_delivery_id] ||= self.supplier_delivery.id if self.supplier_delivery
  end

  protected

  def send_notifications
    # shopping_cart has its notifications
    return if source == 'shopping_cart_plugin'
    # ignore when status is being rewinded
    return if (Statuses.index(self.status) <= Statuses.index(self.status_was) rescue false)

    if self.status == 'ordered' and not [nil, 'ordered'].include? self.status_was
      OrdersPlugin::Mailer.sale_confirmation(self).deliver
    elsif self.status == 'cancelled' and self.status_was != 'cancelled'
      OrdersPlugin::Mailer.sale_cancellation(self).deliver
    elsif self.status == 'received' and self.status_was != 'received'
      OrdersPlugin::Mailer.sale_received(self).deliver
    end
  end
end
