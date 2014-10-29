require 'oauth_plugin'

class FbAppPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t 'fb_app_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t 'fb_app_plugin.lib.plugin.description'
  end

  def self.config
    @config ||= YAML.load File.read("#{File.dirname __FILE__}/../config.yml") rescue {}
  end

  def self.oauth_client_for owner
    @oauth_clients ||= {}
    @oauth_clients["#{owner.class.name}##{owner.id}"] ||= begin
      app_id = config['app']['id']
      app_secret = config['app']['secret']
      client = OauthPlugin::Client.where(client_id: app_id, oauth2_client_owner_id: owner.id, oauth2_client_owner_type: owner.class.name).first
      pp client
      client ||= OauthPlugin::Client.new client_id: app_id
      client.attributes = {
        name: "fb_app_plugin #{app_id}", site: 'https://facebook.com',
        redirect_uri: 'https://anyfornow.net/none',
        client_id: app_id, client_secret: app_secret,
        oauth2_client_owner_id: owner.id, oauth2_client_owner_type: owner.class.name,
      }
      pp client.changed_attributes
      pp client.changed?
      client.save! if client.changed?
      client
    end
  end

  def stylesheet?
    true
  end

  def js_files
    ['fb_app_plugin.js'].map{ |j| "javascripts/#{j}" }
  end

  def head_ending
    lambda do
      tag 'meta', property: 'fb:app_id', content: FbAppPlugin.config['app']['id']
    end
  end

  def control_panel_buttons
    { title: self.class.plugin_name, icon: 'fb-app', url: {controller: :fb_app_plugin_myprofile} }
  end

end

# workaround for plugins' scope problem
require_dependency 'fb_app_plugin/display_helper'
FbAppPlugin::FbAppDisplayHelper = FbAppPlugin::DisplayHelper


