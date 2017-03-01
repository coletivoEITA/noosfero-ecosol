class OrdersCyclePlugin::OrdersCycleHappeningBlock < Block

  def self.description
    _('A block with all the cycle open for orders')
  end

  def default_title
    _('Order Cycles Happening')
  end

  def help
    _('This block lists all the cycles open for orders with its information and a link to order')
  end
end
