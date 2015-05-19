class OrdersCyclePlugin::Purchase < OrdersPlugin::Purchase

  include OrdersCyclePlugin::OrderBase

  has_many :cycles, through: :cycle_purchases, source: :cycle

  scope :for_cycle, lambda{ |cycle| {conditions: ['orders_cycle_plugin_cycles.id = ?', cycle.id], joins: [:cycles]} }

end
