class OrdersCyclePlugin::Purchase < OrdersPlugin::Purchase

  has_many :cycle_orders, class_name: 'OrdersCyclePlugin::CycleOrder', foreign_key: :purchase_id, dependent: :destroy
  has_many :cycles, through: :cycle_orders, source: :cycle

  include OrdersCyclePlugin::OrderBase

  scope :for_cycle, lambda{ |cycle| {conditions: ['orders_cycle_plugin_cycles.id = ?', cycle.id], joins: [:cycles]} }

end
