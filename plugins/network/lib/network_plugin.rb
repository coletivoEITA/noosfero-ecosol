# encoding: UTF-8

class NetworkPlugin < Noosfero::Plugin

  def self.plugin_name
    "Network Plugin"
  end

  def self.plugin_description
    _("A plugin use to create and manage networks at Cirandas.")
  end

  def control_panel_buttons
    buttons = Array.new
    if context.profile.instance_of? NetworkPlugin::Network
      buttons << {:title => 'Informações e configurações da rede', :icon => '', 
        :url => {:controller => 'profile_editor', :action => 'edit'}}
      buttons << {:title => 'Gerenciar estrutura da rede', :icon => '', 
        :url => {:controller => 'network_plugin_myprofile', 
        :action => 'show_structure',
        :id => context.profile}}
    end 
  end
end
