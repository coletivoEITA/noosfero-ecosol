require_dependency 'suppliers_plugin/base_product'

class SuppliersPlugin::BaseProduct

  named_scope :in_cycle, :conditions => ["products.type = 'OrdersCyclePlugin::OfferedProduct'"]

end
