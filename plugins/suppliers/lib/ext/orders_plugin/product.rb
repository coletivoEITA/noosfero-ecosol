require_dependency "orders_plugin/ordered_product"

class OrdersPlugin::OrderedProduct

  delegate :supplier, :to => :product

end
