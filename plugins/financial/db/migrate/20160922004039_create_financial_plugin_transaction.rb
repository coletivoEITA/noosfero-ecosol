class CreateFinancialPluginTransaction < ActiveRecord::Migration
  def change
    create_table :financial_plugin_transactions do |t|

      t.references :target,      polymorphic: true
      t.references :target_profile,    index: true, default: nil
      t.integer    :origin_id,         index: true, default: nil

      t.integer    :order_id,          index: true, default: nil
      t.integer    :payment_id,        index: true, default: nil
      t.integer    :payment_method_id, index: true, default: nil
      t.integer    :operator_id,       index: true, default: nil

      t.text       :description
      t.string     :direction
      t.decimal    :balance
      t.decimal    :value
      t.datetime   :date
      t.timestamps
    end
  end
end
