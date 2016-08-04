class CreateSuppliersPluginHubs < ActiveRecord::Migration
  def change
    create_table :suppliers_plugin_hubs do |t|
      t.string :name
      t.string :description
      t.references :profile, index: true, foreign_key: true
    end
  end
end
