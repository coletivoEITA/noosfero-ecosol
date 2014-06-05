require_dependency 'product'

class Product

  has_many :stock_place_products, :class_name => 'StockPlugin::PlaceProduct'
  has_many :stock_places, :through => :stock_place_products, :source => :place

end
