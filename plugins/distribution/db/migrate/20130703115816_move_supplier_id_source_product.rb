class DistributionPluginProduct < ActiveRecord::Base
  belongs_to :supplier, :class_name => 'SuppliersPlugin::Supplier'
end
class DistributionPluginDistributedProduct < DistributionPluginProduct
end
class DistributionPluginSessionProduct < DistributionPluginProduct
end
class DistributionPluginSourceProduct < ActiveRecord::Base
  belongs_to :to_product, :class_name => "DistributionPluginProduct"
end

class MoveSupplierIdSourceProduct < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_source_products, :supplier_id, :integer

    ::ActiveRecord::Base.transaction do
      DistributionPluginSourceProduct.all.each do |sp|
        next if sp.to_product.nil?
        sp.update_attribute! :supplier_id, sp.to_product.supplier.profile_id
      end
    end

    remove_column :distribution_plugin_products, :supplier_id
  end

  def self.down
    say "this migration can't be reverted"
  end
end
