ActiveSupport.on_load :suppliers_plugin_extensions do
  require_dependency 'suppliers_plugin/supplier'
  require_dependency 'suppliers_plugin/source_product'

  class SuppliersPlugin::Supplier

    acts_as_paranoid

    soft_delete_associations_with_deleted :profile, :consumer

  end

  class SuppliersPlugin::SourceProduct

    acts_as_paranoid

    soft_delete_associations_with_deleted :from_product, :to_product, :supplier,
      :sources_from_products

  end

end
