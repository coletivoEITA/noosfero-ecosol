require_dependency 'orders_plugin/sale'

class OrdersPlugin::Sale

  def order_cycle
    @order_cycle ||= self.cycles.select{ |c| c.profile == self.profile }.first
  end
  alias_method :cycle, :order_cycle

  def current_status_with_order_cycle
    return 'forgotten' if self.forgotten?
    self.current_status_without_order_cycle
  end
  alias_method_chain :current_status, :order_cycle

  def delivery?
    self.order_cycle.delivery?
  end
  def forgotten?
    self.draft? and !self.order_cycle.orders?
  end

  def open_with_order_cycle?
    return self.open_without_order_cycle? if self.order_cycle.blank?
    self.open_without_order_cycle? and self.order_cycle.orders?
  end
  alias_method_chain :open?, :order_cycle

  def supplier_delivery_with_order_cycle
    self.supplier_delivery_without_order_cycle || (self.order_cycle.delivery_methods.first rescue nil)
  end
  def supplier_delivery_id_with_order_cycle
    self['supplier_delivery_id'] || (self.order_cycle.delivery_methods.first.id rescue nil)
  end
  alias_method_chain :supplier_delivery, :order_cycle

  protected

end
