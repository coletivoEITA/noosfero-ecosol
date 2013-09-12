Object.send :remove_const, :Product

class SuppliersPlugin::SourceProduct < Noosfero::Plugin::ActiveRecord
  belongs_to :from_product, :class_name => 'Product'
end
class Product < ActiveRecord::Base
  has_many :sources_from_products, :class_name => 'SuppliersPlugin::SourceProduct', :foreign_key => :to_product_id, :dependent => :destroy
  has_many :from_products, :through => :sources_from_products, :order => 'id ASC'
end
SuppliersPlugin.remove_const :DistributedProduct if defined? SuppliersPlugin::DistributedProduct
class SuppliersPlugin::DistributedProduct < Product
end

class MoveDefaultDataFromDistributedToProduct < ActiveRecord::Migration
  def self.up
    SuppliersPlugin::DistributedProduct.find_each do |distributed_product|

      distributed_product.from_products.each do |product|

        [:name, :description, :price, :unit_id, :product_category_id].each do |attr|
          product[attr] = distributed_product[attr] if product[attr].blank?
          distributed_product[attr] = nil
        end

        product.save!
      end
      distributed_product.save!
    end
  end

  def self.down
  end
end
