class DistributionPlugin < Noosfero::Plugin
  def self.plugin_name
    "Distribution"
  end

  def self.plugin_description
    _("A solidary distribution plugin.")
  end

  def stylesheet?
    true
  end

  def js_files
    ['underscore-min', 'backbone-min',
     'distribution']
  end

  def control_panel_buttons
    profile = context.profile
    node = DistributionPluginNode.find_or_create(profile)
    { :title => _('Distribution'), :icon => nil, :url => {:plugin_name => 'distribution', :controller => node.myprofile_controller, :profile => profile.identifier, :action => 'index'} }
  end

end
