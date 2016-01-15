class ChangeExchangePluginProposalAddExchangeId < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_proposals, :exchange_id, :integer 
  end

  def self.down
    remove_column :exchange_plugin_proposals, :exchange_id, :integer 
  end
end
