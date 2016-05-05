require_dependency 'product'

class Product

  has_many :elements, -> {
    where object_type: 'Product'
  }, foreign_key: :object_id, class_name: 'ExchangePlugin::Element', dependent: :destroy

end
