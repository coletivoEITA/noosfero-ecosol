class NetworksPlugin::Network < NetworksPlugin::BaseNode

  def control_panel_settings_button
    {:title => I18n.t('networks_plugin.models.network.settings_button'), :icon => 'edit-profile-enterprise'}
  end

  protected

  def default_template
    return if self.is_template
    self.environment.network_template
  end

end
