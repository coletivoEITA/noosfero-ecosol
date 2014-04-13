class OrdersPlugin::Sale < OrdersPlugin::Order

  def orders_name
    'orders'
  end

  def purchase_quantity_total
    #TODO
    self.total_quantity_consumer_asked
  end
  def purchase_price_total
    #TODO
    self.total_price_consumer_asked
  end

  has_number_with_locale :purchase_quantity_total
  has_currency :purchase_price_total

  protected

end
