class OrdersPlugin::Sale < OrdersPlugin::Order

  def orders_name
    'orders'
  end

  def purchase_quantity_total
    #TODO
    total_quantity_asked
  end
  def purchase_price_total
    #TODO
    total_price_asked
  end

  has_number_with_locale :purchase_quantity_total
  has_currency :purchase_price_total

  protected

end
