require_dependency 'orders_plugin/item'

class OrdersPlugin::Item

  has_one :supplier, :through => :product

  belongs_to :offered_product, :foreign_key => :product_id, :class_name => 'OrdersCyclePlugin::OfferedProduct'

end

