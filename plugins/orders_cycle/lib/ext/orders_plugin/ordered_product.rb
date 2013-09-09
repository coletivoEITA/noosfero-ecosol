require_dependency 'orders_plugin/ordered_product'

class OrdersPlugin::OrderedProduct

  has_one :supplier, :through => :product

  has_many :cycles, :through => :order, :class_name => 'OrdersCyclePlugin::Cycle'
  def cycle
    self.cycles.first
  end

  belongs_to :offered_product, :foreign_key => :product_id, :class_name => 'OrdersCyclePlugin::OfferedProduct'

end

