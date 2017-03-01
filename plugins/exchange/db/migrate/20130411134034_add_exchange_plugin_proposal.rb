class AddExchangePluginProposal < ActiveRecord::Migration
  def self.up
    create_table :exchange_plugin_proposals do |t|
      t.integer :enterprise_target_id
      t.integer :enterprise_origin_id
      t.timestamps
    end
  end

  def self.down
    drop_table :exchange_plugin_proposal
  end
end
