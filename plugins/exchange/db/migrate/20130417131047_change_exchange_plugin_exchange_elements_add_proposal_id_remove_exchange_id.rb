class ChangeExchangePluginExchangeElementsAddProposalIdRemoveExchangeId < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_exchange_elements, :proposal_id, :integer
    remove_column :exchange_plugin_exchange_elements, :exchange_id
  end

  def self.down
    remove_column :exchange_plugin_exchange_elements, :proposal_id, :integer
    add_column :exchange_plugin_exchange_elements, :exchange_id, :integer
  end
end
