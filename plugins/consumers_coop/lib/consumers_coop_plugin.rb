require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/category"

class ConsumersCoopPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('consumers_coop_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('consumers_coop_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['consumers_coop'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    profile = context.profile
    return nil unless profile.community?
    { :title => I18n.t('consumers_coop_plugin.lib.plugin.name'), :icon => 'consumers-coop', :url => {:controller => :consumers_coop_plugin_myprofile, :profile => profile.identifier, :action => :settings} }
  end

end

# workaround for plugin class scope problem
require_dependency 'consumers_coop_plugin/layout_helper'


