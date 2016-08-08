class AddProfileFieldsToSuppliers < ActiveRecord::Migration
  def change
    remove_column :suppliers_plugin_suppliers, :use_geolocalization, :boolean
    remove_column :suppliers_plugin_suppliers, :use_contact, :boolean
    remove_column :suppliers_plugin_suppliers, :use_registry, :boolean
    remove_column :suppliers_plugin_suppliers, :use_strategic_info, :boolean
    add_column :suppliers_plugin_suppliers, :phone, :string
    add_column :suppliers_plugin_suppliers, :cell_phone, :string
    add_column :suppliers_plugin_suppliers, :email, :string
    add_column :suppliers_plugin_suppliers, :hub_id, :integer
    add_column :suppliers_plugin_suppliers, :address, :string
    add_column :suppliers_plugin_suppliers, :city, :string
    add_column :suppliers_plugin_suppliers, :state, :string
    add_column :suppliers_plugin_suppliers, :zip, :string
    add_index  :suppliers_plugin_suppliers, :hub_id
  end
end
