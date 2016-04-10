ActiveSupport.on_load :orders_cycle_plugin_extensions do
  require_relative 'product'
  require_relative '../../../suppliers/lib/ext/product'
  require_dependency 'orders_cycle_plugin/offered_product'

  class OrdersCyclePlugin::OfferedProduct

    soft_delete_associations_with_deleted :suppliers, :supplier,
      :sources_supplier_products, :sources_supplier_product, :supplier_products, :supplier_product,
      :cycles, :cycle

  end
end

