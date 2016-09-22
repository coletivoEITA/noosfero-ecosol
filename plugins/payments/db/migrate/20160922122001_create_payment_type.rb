class CreatePaymentType < ActiveRecord::Migration
  def change
    create_table :payments_plugin_payment_types do |t|
      t.string :slug
      t.string :name
      t.text :description
    end
  end
end
