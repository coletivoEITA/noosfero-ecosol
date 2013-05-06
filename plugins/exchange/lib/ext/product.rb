require_dependency '../../../../app/models/product'

class Product
  has_many :elements, :foreign_key => "element_id", :conditions => {:element_type => "Product"}, :class_name => 'ExchangePlugin::ExchangeElement', :dependent => :destroy
end
