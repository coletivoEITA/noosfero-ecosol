require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/community"
require_dependency "#{File.dirname __FILE__}/ext/category"
require_dependency "#{File.dirname __FILE__}/ext/product"

require_dependency "#{File.dirname __FILE__}/ext/delivery_plugin/delivery_option"

require_dependency "#{File.dirname __FILE__}/ext/orders_plugin/order"
require_dependency "#{File.dirname __FILE__}/ext/orders_plugin/ordered_product"

require_dependency "#{File.dirname __FILE__}/ext/suppliers_plugin/supplier"
require_dependency "#{File.dirname __FILE__}/ext/suppliers_plugin/base_product"
require_dependency "#{File.dirname __FILE__}/ext/suppliers_plugin/distributed_product"

class DistributionPlugin < Noosfero::Plugin

  def self.plugin_name
    "Distribution"
  end

  def self.plugin_description
    I18n.t('distribution_plugin.lib.a_solidary_distributi')
  end

  def stylesheet?
    true
  end

  def js_files
    ['underscore-min.js', 'toggle_edit', 'distribution']
  end

  def profile_blocks profile
    DistributionPlugin::OrderBlock if DistributionPlugin::OrderBlock.available_for? profile
  end

  def control_panel_buttons
    profile = context.profile
    return nil unless profile.community?
    node = DistributionPlugin::Node.find_or_create(profile)
    { :title => I18n.t('distribution_plugin.lib.settings_solidary_dis'), :icon => 'distribution-solidary-network', :url => {:controller => :distribution_plugin_node, :profile => profile.identifier, :action => :settings} }
  end

end
