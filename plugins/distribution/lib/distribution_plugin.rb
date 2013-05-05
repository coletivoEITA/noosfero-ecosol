require_dependency 'ext/profile'
require_dependency 'ext/community'
require_dependency 'ext/category'
require_dependency 'ext/product'

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
    _("A solidary distribution plugin.")
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
    { :title => _('Settings Solidary Distribution Network'), :icon => 'distribution-solidary-network', :url => {:controller => :distribution_plugin_node, :profile => profile.identifier, :action => :settings} }
  end

end
