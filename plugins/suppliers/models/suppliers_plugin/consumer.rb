class SuppliersPlugin::Consumer < SuppliersPlugin::Supplier

  set_table_name :suppliers_plugin_suppliers

  belongs_to :profile, :foreign_key => :consumer_id

  def name
    self.profile.name
  end

end
