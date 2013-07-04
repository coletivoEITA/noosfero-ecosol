require_dependency 'suppliers_plugin/base_product'

class SuppliersPlugin::BaseProduct

  has_one :node, :through => :profile
  def node
    self.profile.distribution_node
  end

  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :node
  settings_default_item :margin_fixed, :type => :boolean, :default => true, :delegate_to => :node

end
