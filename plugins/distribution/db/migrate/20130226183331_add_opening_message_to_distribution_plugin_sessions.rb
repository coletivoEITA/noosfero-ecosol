class AddOpeningMessageToDistributionPluginSessions < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_sessions, :opening_message, :text
  end

  def self.down
    remove_column :distribution_plugin_sessions, :opening_message
  end
end
