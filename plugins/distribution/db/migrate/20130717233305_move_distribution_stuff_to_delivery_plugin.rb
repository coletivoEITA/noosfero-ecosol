class DistributionPlugin::Node < Noosfero::Plugin::ActiveRecord
  belongs_to :profile
end
class DistributionPlugin::DeliveryMethod < Noosfero::Plugin::ActiveRecord
  belongs_to :node, :class_name => 'DistributionPlugin::Node'
end
class DistributionPlugin::DeliveryOption < Noosfero::Plugin::ActiveRecord
end

class MoveDistributionStuffToDeliveryPlugin < ActiveRecord::Migration
  def self.up

    rename_column :distribution_plugin_delivery_methods, :node_id, :profile_id
    DistributionPlugin::DeliveryMethod.all.each do |method|
      method.update_attributes! :profile_id => method.node.profile_id
    end
    rename_table :distribution_plugin_delivery_methods, :delivery_plugin_methods

    rename_column :distribution_plugin_delivery_options, :session_id, :owner_id
    add_column :distribution_plugin_delivery_options, :session_id, :owner_type, :integer
    DistributionPlugin::DeliveryOption.update_all ["owner_type = 'DistributionPlugin::Session'"]
    rename_table :distribution_plugin_delivery_options, :delivery_plugin_options

  end

  def self.down
  end
end
