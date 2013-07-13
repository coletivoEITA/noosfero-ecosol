require_dependency 'suppliers_plugin/base_product'

class SuppliersPlugin::BaseProduct

  has_one :node, :through => :profile
  def node
    self.profile.distribution_node
  end

  named_scope :in_session, :conditions => ["products.type = 'DistributionPlugin::OfferedProduct'"]
  named_scope :for_session_id, lambda { |session_id| {
      :conditions => ['distribution_plugin_session_products.session_id = ?', session_id],
      :joins => 'INNER JOIN distribution_plugin_session_products ON products.id = distribution_plugin_session_products.product_id'
    }
  }

  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :node
  settings_default_item :margin_fixed, :type => :boolean, :default => true, :delegate_to => :node

end
