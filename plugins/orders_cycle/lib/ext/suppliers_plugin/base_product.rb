require_dependency 'suppliers_plugin/base_product'

class SuppliersPlugin::BaseProduct

  scope :in_cycle, -> { where "products.type = 'OrdersCyclePlugin::OfferedProduct'" }

end
