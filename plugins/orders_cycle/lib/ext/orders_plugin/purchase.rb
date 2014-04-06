require_dependency 'orders_plugin/purchase'

class OrdersPlugin::Purchase

  def purchase_cycle
    @purchase_cycle ||= self.cycles.select{ |c| c.profile == self.consumer }.first
  end
  alias_method :cycle, :purchase_cycle

end
