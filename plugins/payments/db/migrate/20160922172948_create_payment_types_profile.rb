class CreatePaymentTypesProfile < ActiveRecord::Migration
  def change
    create_table :payments_plugin_payment_types_profiles do |t|
      t.belongs_to :profile, index: true
      t.belongs_to :payment_type, index: true
    end
  end
end
