require_dependency 'product_category'

#FIXME: move into core
class ProductCategory

  has_many :enterprises, :through => :products

end

