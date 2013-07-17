class DistributionPluginSessionProduct < ActiveRecord::Base
end

class DistributionPluginProduct < ActiveRecord::Base
end
class DistributionPluginOfferedProduct < DistributionPluginProduct
end

class PutSessionIdInRelation < ActiveRecord::Migration
  def self.up
    create_table :distribution_plugin_session_products do |t|
      t.integer :session_id
      t.integer :product_id
    end

    DistributionPluginProduct.update_all "type = 'DistributionPluginOfferedProduct'", "type = 'DistributionPluginSessionProduct'"

    ::ActiveRecord::Base.transaction do
      DistributionPluginProduct.all(:conditions => ['session_id IS NOT NULL']).each do |product|
        DistributionPluginSessionProduct.create! :session_id => product.session_id, :product_id => product.id
      end
    end

    add_index :distribution_plugin_session_products, [:session_id, :product_id], :unique => true
    remove_column :distribution_plugin_products, :session_id
  end

  def self.down
    drop_table :distribution_plugin_session_products
  end
end
