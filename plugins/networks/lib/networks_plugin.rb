# encoding: UTF-8

class NetworksPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t("Networks")
    I18n.t('networks_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('networks_plugin.lib.plugin.description')
  end

  def control_panel_buttons
    buttons = []
    if context.profile.is_a? NetworksPlugin::Network
      buttons << {:title => I18n.t('networks_plugin.lib.plugin.info_control_panel_button'), :icon => '',
        :url => {:controller => :profile_editor, :action => :edit}}
      buttons << {:title => I18n.t('networks_plugin.lib.plugin.manage_control_panel_button'), :icon => '',
        :url => {:controller => :networks_plugin_myprofile, :action => :show_structure, :identifier => context.profile.identifier}}
    end
    buttons
  end
end
