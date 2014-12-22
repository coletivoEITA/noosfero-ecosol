require_dependency 'product'

class Product

  has_many :stock_allocations, :class_name => 'StockPlugin::Allocation'
  has_many :stock_places, :through => :stock_allocations, :source => :place

end
