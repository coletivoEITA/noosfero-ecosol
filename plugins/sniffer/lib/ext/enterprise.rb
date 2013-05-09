require_dependency 'enterprise'

class Enterprise
  has_many :input_categories, :through => :inputs, :source => :product_category, :uniq => true
  has_many :product_categories, :through => :products, :source => :product_category, :uniq => true
end
