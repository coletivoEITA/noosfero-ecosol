require_dependency 'product'

class Product

  acts_as_paranoid

end

ActiveSupport.on_load :suppliers_plugin_extensions do
  require_relative '../../../suppliers/lib/ext/product'

  Product.soft_delete_associations_with_deleted \
    :sources_from_products, :sources_from_product, :from_products, :from_product,
    :sources_supplier_products, :sources_supplier_product, :supplier_products, :supplier_product,
    :suppliers, :supplier, :consumers, :consumer
end

