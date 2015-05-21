class OrdersCyclePlugin::Purchase < OrdersPlugin::Purchase

  include OrdersCyclePlugin::OrderBase

  has_many :cycles, through: :cycle_purchases, source: :cycle

end
