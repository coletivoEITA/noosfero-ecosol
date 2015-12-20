class ChangeExchangePluginMessageAddProposalIdRemoveExchangeId < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_messages, :proposal_id, :integer
    remove_column :exchange_plugin_messages, :exchange_id
  end

  def self.down
    remove_column :exchange_plugin_messages, :proposal_id
    add_column :exchange_plugin_messages, :exchange_id, :integer
  end

end
