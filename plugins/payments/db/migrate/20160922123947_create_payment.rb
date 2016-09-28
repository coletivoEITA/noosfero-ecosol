class CreatePayment < ActiveRecord::Migration
  def change
    create_table :payments_plugin_payments do |t|
      t.references :orders_plugin_order, index: true, foreign_key: true
      t.references :profile, index: true, foreign_key: true
      t.integer :payment_method_id
      t.integer :operator_id
      t.decimal :value
      t.text :description
    end
    add_index :payments_plugin_payments, :payment_method_id, name: 'index_payments_on_payment_method_id'
    add_index :payments_plugin_payments, :operator_id,     name: 'index_payments_on_operator_id'
  end
end
