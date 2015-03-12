class CreateSmssyncPluginMessage < ActiveRecord::Migration
  def up
    create_table :smssync_plugin_messages do |t|
      t.string :uuid
      t.integer :chat_message_id

      t.integer :from_profile_id
      t.integer :to_profile_id
      t.string :from
      t.string :sent_to

      t.string :device_id
      t.text :message
      t.datetime :sent_timestamp

      t.timestamps
    end
  end

  def down
    drop_table :smssync_plugin_messages
  end
end
