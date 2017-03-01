class OrdersPlugin::Purchase < OrdersPlugin::Order

  after_save :send_notifications

  def orders_name
    'purchases'
  end
  def actor_name
    :supplier
  end

  protected

  def send_notifications
    # shopping_cart has its notifications
    return if source == 'shopping_cart_plugin'
    # ignore when status is being rewinded
    return if (Statuses.index(self.status) <= Statuses.index(self.status_was) rescue false)

    if self.status == 'ordered' and self.status_was != 'ordered'
      OrdersPlugin::Mailer.purchase_confirmation(self).deliver
    elsif self.status == 'cancelled' and self.status_was != 'cancelled'
      OrdersPlugin::Mailer.purchase_cancellation(self).deliver
    elsif self.status == 'received' and self.status_was != 'received'
      OrdersPlugin::Mailer.purchase_received(self).deliver
    end
  end
end
