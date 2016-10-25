class CreateFinancialPluginTransaction < ActiveRecord::Migration
  def change
    create_table :financial_plugin_transactions do |t|
      t.references :profile, index: true, foreign_key: true
      t.references :context, polymorphic: true
      t.references :target,  polymorphic: true
      t.references :source,  polymorphic: true
      t.integer    :operator_id, index: true
      t.decimal    :value
      t.text       :description
      t.string     :category
      t.string     :direction
      t.decimal    :balance
      t.timestamps
    end
  end
end
