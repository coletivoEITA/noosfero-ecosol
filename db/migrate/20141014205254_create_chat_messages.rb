class CreateChatMessages < ActiveRecord::Migration
  def up
    create_table :chat_messages do |t|
      t.references :from
      t.references :to
      t.text   :body
      t.timestamps
    end
    add_index :chat_messages, :from
    add_index :chat_messages, :to
    add_index :chat_messages, :created_at
  end

  def down
    drop_table :chat_messages
    remove_index :chat_messages, :from
    remove_index :chat_messages, :to
    remove_index :chat_messages, :created_at
  end
end
