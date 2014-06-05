require_dependency 'profile'

class Profile

  has_many :stock_places, :class_name => 'StockPlugin::Place'

end

