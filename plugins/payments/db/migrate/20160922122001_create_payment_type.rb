class CreatePaymentType < ActiveRecord::Migration
  def up
    create_table :payments_plugin_payment_types do |t|
      t.string :slug
      t.string :name
      t.text :description, default: ""
    end
    execute "INSERT INTO payments_plugin_payment_types (slug, name) VALUES ('money', 'money'), ('check', 'check'), ('credit_card', 'credit_card'), ('bank_transfer', 'bank_transfer'), ('boleto', 'boleto');"
  end
  def down
    drop_table :payments_plugin_payment_types
  end
end
