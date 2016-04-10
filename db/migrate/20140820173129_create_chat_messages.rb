class CreateChatMessages < ActiveRecord::Migration
  def up
    create_table :chat_messages do |t|
      t.integer :to_id
      t.integer :from_id
      t.string :body

      t.timestamps
    end
    add_index :chat_messages, :from_id
    add_index :chat_messages, :to_id
    add_index :chat_messages, :created_at
  end

  def down
    drop_table :chat_messages
  end
end
