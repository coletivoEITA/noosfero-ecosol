require_dependency 'product'

class Product

  has_many :elements, :foreign_key => :object_id, :conditions => {:object_type => "Product"},
    :class_name => 'ExchangePlugin::Element', :dependent => :destroy

end
