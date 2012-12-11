class AddStatusToSession < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_sessions, :status, :string
  end

  def self.down
    remove_column :distribution_plugin_sessions, :status
  end
end
