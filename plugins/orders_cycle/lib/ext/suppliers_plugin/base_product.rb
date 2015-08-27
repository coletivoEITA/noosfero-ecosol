require_dependency 'suppliers_plugin/base_product'

class SuppliersPlugin::BaseProduct

  scope :in_cycle, conditions: ["products.type = 'OrdersCyclePlugin::OfferedProduct'"]

end
