class SuppliersPlugin::Consumer < SuppliersPlugin::Supplier
  set_table_name :suppliers_plugin_suppliers

  belongs_to :profile, :foreign_key => :consumer_id
  belongs_to :supplier, :foreign_key => :profile_id, :class_name => 'Profile'

end
