require_dependency 'suppliers_plugin/base_product'

class SuppliersPlugin::BaseProduct

  named_scope :in_session, :conditions => ["products.type = 'DistributionPlugin::OfferedProduct'"]
  named_scope :for_session_id, lambda { |session_id| {
      :conditions => ['distribution_plugin_session_products.session_id = ?', session_id],
      :joins => 'INNER JOIN distribution_plugin_session_products ON products.id = distribution_plugin_session_products.product_id'
    }
  }

  has_number_with_locale :margin_percentage
  has_number_with_locale :own_margin_percentage
  has_number_with_locale :original_margin_percentage
  has_number_with_locale :margin_fixed
  has_number_with_locale :own_margin_fixed
  has_number_with_locale :original_margin_fixed

  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :distribution_node
  settings_default_item :margin_fixed, :type => :boolean, :default => true, :delegate_to => :distribution_node

  def price_with_margins base_price = nil, margin_source = nil
    price = 0 unless price
    base_price ||= price
    margin_source ||= self
    ret = base_price

    if margin_source.margin_percentage
      ret += (margin_source.margin_percentage / 100) * ret
    elsif self.distribution_node.margin_percentage
      ret += (self.distribution_node.margin_percentage / 100) * ret
    end
    if margin_source.margin_fixed
      ret += margin_source.margin_fixed
    elsif self.distribution_node.margin_fixed
      ret += self.distribution_node.margin_fixed
    end

    ret
  end

end
