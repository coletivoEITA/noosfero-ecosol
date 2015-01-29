class AddFieldsToSuppliersPluginSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers_plugin_suppliers, :qualifiers, :string
    add_column :suppliers_plugin_suppliers, :tags, :string
    add_column :suppliers_plugin_suppliers, :use_strategic_info, :boolean
    add_column :suppliers_plugin_suppliers, :use_contact, :boolean
    add_column :suppliers_plugin_suppliers, :use_registry, :boolean
    add_column :suppliers_plugin_suppliers, :use_geolocalization, :boolean
    add_column :suppliers_plugin_suppliers, :lat, :string
    add_column :suppliers_plugin_suppliers, :lng, :string
  end
end
