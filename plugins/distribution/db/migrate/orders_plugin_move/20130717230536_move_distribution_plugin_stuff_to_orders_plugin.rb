class DistributionPlugin::Node < Noosfero::Plugin::ActiveRecord
end
class DistributionPlugin::Session < Noosfero::Plugin::ActiveRecord
  belongs_to :node, :class_name => 'DistributionPlugin::Node'
end
class DistributionPlugin::Order < Noosfero::Plugin::ActiveRecord
  belongs_to :consumer, :class_name => 'DistributionPlugin::Node'
end
class DistributionPlugin::OrderedProduct < Noosfero::Plugin::ActiveRecord
end

class DistributionPlugin::SessionOrder < Noosfero::Plugin::ActiveRecord
end

class MoveDistributionPluginStuffToOrdersPlugin < ActiveRecord::Migration
  def self.up
    create_table :distribution_plugin_session_orders do |t|
      t.integer :session_id
      t.integer :order_id
      t.timestamps
    end

    rename_column :distribution_plugin_orders, :session_id, :profile_id
    ::ActiveRecord::Base.transaction do
      DistributionPlugin::Order.all.each do |order|
        session_id = order.profile_id
        DistributionPlugin::SessionOrder.create! :session_id => session_id, :order_id => order.id

        session = DistributionPlugin::Session.find session_id
        order.update_attributes! :profile_id => session.node.profile_id, :consumer_id => order.consumer.profile_id
      end
    end

    rename_table :distribution_plugin_orders, :orders_plugin_orders
    rename_table :distribution_plugin_ordered_products, :orders_plugin_products

  end

  def self.down
  end
end
