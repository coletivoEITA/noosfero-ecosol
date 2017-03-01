class AddCommentToExchangeElement < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_exchange_elements, :comment, :text

    # refactoring

    rename_table :exchange_plugin_exchange_elements, :exchange_plugin_elements
    remove_column :exchange_plugin_elements, :enterprise
    rename_column :exchange_plugin_elements, :enterprise_id, :profile_id
    rename_column :exchange_plugin_elements, :element_id, :object_id
    rename_column :exchange_plugin_elements, :element_type, :object_type

    rename_column :exchange_plugin_proposals, :date_sent, :sent_at
    rename_column :exchange_plugin_proposals, :enterprise_target_id, :target_id
    rename_column :exchange_plugin_proposals, :enterprise_origin_id, :origin_id

    rename_column :exchange_plugin_messages, :enterprise_sender_id, :sender_id
    rename_column :exchange_plugin_messages, :enterprise_recipient_id, :recipient_id

    rename_table :exchange_plugin_exchange_enterprises, :exchange_plugin_profile_exchanges
    rename_column :exchange_plugin_profile_exchanges, :enterprise_id, :profile_id

    add_index :exchange_plugin_profile_exchanges, [:profile_id, :exchange_id], name: :exchange_4ba6a222
  end

  def self.down
    say "this migration can't be reverted"
  end
end
