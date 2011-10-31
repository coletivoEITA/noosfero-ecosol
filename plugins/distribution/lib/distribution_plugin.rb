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
    ['distribution']
  end

  def control_panel_buttons
    profile = context.profile
    node = DistributionPluginNode.find_or_create(profile)
    { :title => _('Distribution'), :icon => nil, :url => {:plugin_name => 'distribution', :controller => :distribution_plugin_node, :profile => profile.identifier, :action => 'index'} }
  end

end
