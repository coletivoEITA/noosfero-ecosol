class CreatePaymentMethod < ActiveRecord::Migration
  def up
    create_table :payments_plugin_payment_methods do |t|
      t.string :slug
      t.string :name
      t.text :description, default: ""
    end
    execute "INSERT INTO payments_plugin_payment_methods (slug, name) VALUES ('money', 'Money'), ('check', 'Check'), ('credit_card', 'Credit Card'), ('debit_card', 'Debit Card'), ('bank_transfer', 'Bank Transfer'), ('boleto', 'Boleto'), ('other', 'Other');"
  end
  def down
    drop_table :payments_plugin_payment_methods
  end
end
