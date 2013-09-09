require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/community"
require_dependency "#{File.dirname __FILE__}/ext/category"
require_dependency "#{File.dirname __FILE__}/ext/product"

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

  def profile_blocks profile
    ConsumersCoopPlugin::OrderBlock if ConsumersCoopPlugin::OrderBlock.available_for? profile
  end

  def control_panel_buttons
    profile = context.profile
    return nil unless profile.community?
    node = ConsumersCoopPlugin::Node.find_or_create profile
    { :title => I18n.t('consumers_coop_plugin.lib.name'), :icon => 'consumers-coop', :url => {:controller => :consumers_coop_plugin_node, :profile => profile.identifier, :action => :settings} }
  end

end

# workaround for plugin class scope problem
require_dependency 'consumers_coop_plugin/layout_helper'


