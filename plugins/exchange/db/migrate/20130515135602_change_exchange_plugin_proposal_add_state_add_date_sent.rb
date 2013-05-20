class ChangeExchangePluginProposalAddStateAddDateSent < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_proposals, :state, :string
    add_column :exchange_plugin_proposals, :date_sent, :datetime
  end

  def self.down
    remove_column :exchange_plugin_proposals, :state
    remove_column :exchange_plugin_proposals, :date_sent
  end
end
