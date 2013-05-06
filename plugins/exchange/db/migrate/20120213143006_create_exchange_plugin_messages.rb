class CreateExchangePluginMessages < ActiveRecord::Migration
  def self.up
    create_table :exchange_plugin_messages do |t|
      t.integer :exchange_id
      t.text :body
      t.integer :enterprise_sender_id
      t.integer :enterprise_recipient_id
      t.integer :person_sender_id
      t.string :exchange_state

      t.timestamps
    end
  end

  def self.down
    drop_table :exchange_plugin_messages
  end
end
