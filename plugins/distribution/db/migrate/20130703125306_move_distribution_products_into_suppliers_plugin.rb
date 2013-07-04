class DistributionPluginNode < ActiveRecord::Base
  belongs_to :profile
end
class DistributionPluginProduct < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionPluginNode'
end
class DistributionPluginDistributedProduct < DistributionPluginProduct
end
class DistributionPluginSessionProduct < DistributionPluginProduct
end
class SuppliersPlugin::BaseProduct < Product
  validates_uniqueness_of :name, :scope => :profile_id, :allow_nil => true, :if => proc{ |p| false }
end
class SuppliersPlugin::DistributedProduct < SuppliersPlugin::BaseProduct
end
class SuppliersPlugin::SourceProduct < Noosfero::Plugin::ActiveRecord
end

class MoveDistributionProductsIntoSuppliersPlugin < ActiveRecord::Migration
  def self.up
    rename_table :distribution_plugin_source_products, :suppliers_plugin_source_products

    id_translation = {}
    ::ActiveRecord::Base.transaction do
      DistributionPluginProduct.all.each do |product|
        profile = product.node.profile
        new_product = SuppliersPlugin::DistributedProduct.new :enterprise => profile, :name => product.name, :price => product.price, :description => product.description, :available => product.active, :unit_id => product.unit_id
        new_product.data = product.settings
        new_product.data[:margin_fixed] = product.margin_fixed
        new_product.data[:margin_percentage] = product.margin_percentage
        new_product.data[:unit_detail] = product.unit_detail
        new_product.data[:minimum_selleable] = product.minimum_selleable
        new_product.data[:stored] = product.stored
        new_product.data[:quantity] = product.quantity
        new_product.product_category_id = product.category_id || ProductCategory.find_by_name('Produtos').id || ProductCategory.first.id

        new_product.save false
        id_translation[product.id] = new_product.id

        if product.product_id
          SuppliersPlugin::SourceProduct.create! :from_product_id => product.product_id, :to_product_id => new_product.id
        end
      end

      SuppliersPlugin::SourceProduct.all.each do |sp|
        sp.update_attributes! :to_product_id => id_translation[sp.to_product_id], :from_product_id => id_translation[sp.from_product_id]
      end
    end

    drop_table :distribution_plugin_products
  end

  def self.down
  end
end
