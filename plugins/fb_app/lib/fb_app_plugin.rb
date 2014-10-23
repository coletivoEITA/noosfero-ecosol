
class FbAppPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t 'fb_app_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t 'fb_app_plugin.lib.plugin.description'
  end

  def self.config
    YAML.load File.read("#{File.dirname __FILE__}/../config.yml") rescue {}
  end

  def stylesheet?
    true
  end

  def js_files
    ['fb_app_plugin.js', 'typeahead.bundle.js'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    { title: self.class.plugin_name, icon: 'fb-app', url: {controller: :fb_app_plugin_myprofile} }
  end

end

# workaround for plugins' scope problem
require_dependency 'fb_app_plugin/display_helper'
FbAppPlugin::FbAppDisplayHelper = FbAppPlugin::DisplayHelper

