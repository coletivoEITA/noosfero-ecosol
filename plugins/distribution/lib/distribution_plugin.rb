require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/community"
require_dependency "#{File.dirname __FILE__}/ext/category"
require_dependency "#{File.dirname __FILE__}/ext/product"

[ ActiveSupport::Dependencies.load_paths, $:].each do |path|
  vendor = Dir.glob File.join(File.dirname(__FILE__), '/../vendor/plugins/*')
  vendor.each do |plugin|
    path << plugin + '/lib'
  end
end

class DistributionPlugin < Noosfero::Plugin

  def self.plugin_name
    "Distribution"
  end

  def self.plugin_description
    I18n.t('distribution_plugin.lib.a_solidary_distributi')
  end

  def self.view_path
    RAILS_ROOT +  "/plugins/distribution/views"
  end

  def stylesheet?
    true
  end

  def profile_blocks(profile)
    DistributionPlugin::OrderBlock if DistributionPlugin::OrderBlock.available_for(profile)
  end

  def js_files
    ['underscore-min.js', 'distribution']
  end

  def control_panel_buttons
    profile = context.profile
    return nil unless profile.community?
    node = DistributionPluginNode.find_or_create(profile)
    { :title => I18n.t('distribution_plugin.lib.settings_solidary_dis'), :icon => 'distribution-solidary-network', :url => {:controller => :distribution_plugin_node, :profile => profile.identifier, :action => :settings} }
  end

end
