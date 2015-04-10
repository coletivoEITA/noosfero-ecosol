class ConsumersCoopPlugin::Base < Noosfero::Plugin

  def stylesheet?
    true
  end

  def js_files
    ['consumers_coop'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    profile = context.profile
    return unless profile.community? or profile.consumers_coop_settings.enabled
    { title: I18n.t('consumers_coop_plugin.lib.plugin.name'), icon: 'consumers-coop', url: {controller: :consumers_coop_plugin_myprofile, profile: profile.identifier, action: :settings} }
  end

end

