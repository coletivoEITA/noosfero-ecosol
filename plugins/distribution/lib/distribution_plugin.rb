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
    ['distribution', 'jquery.ba-bbq.min.js', 'url']
  end

  def control_panel_buttons
    profile = context.profile
    node = DistributionPluginNode.find_or_create(profile)
    { :title => _('Distribution'), :icon => nil, :url => {:controller => node.myprofile_controller, :profile => profile.identifier, :action => 'index'} }
  end

  def custom_contents
    [:header]
  end

end
