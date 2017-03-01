class CreatePaymentMethodsProfile < ActiveRecord::Migration
  def change
    create_table :payments_plugin_payment_methods_profiles do |t|
      t.belongs_to :profile, index: true
      t.belongs_to :payment_method
    end
    add_index :payments_plugin_payments, :payment_method_id, name: 'index_payment_methods_profiles_on_payment_method_id'
  end
end
