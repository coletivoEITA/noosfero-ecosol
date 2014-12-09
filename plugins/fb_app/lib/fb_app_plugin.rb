class FbAppPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t 'fb_app_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t 'fb_app_plugin.lib.plugin.description'
  end

  def self.config
    @config ||= HashWithIndifferentAccess.new(YAML.load File.read("#{File.dirname __FILE__}/../config.yml")) rescue {}
  end

  def self.oauth_provider_for environment
    return unless self.config.present?

    @oauth_providers ||= {}
    @oauth_providers[environment] ||= begin
      app_id = self.timeline_app_credentials[:id]
      app_secret = self.timeline_app_credentials[:secret]

      client = OauthPlugin::Provider.where(environment_id: environment.id, key: app_id).first
      client ||= OauthPlugin::Provider.new

      client.attributes = {
        strategy: 'facebook', identifier: "fb_app_plugin_#{app_id}",
        name: 'FB App', site: 'https://facebook.com',
        key: app_id, secret: app_secret,
        environment_id: environment.id
      }
      client.save! if client.changed?
      client
    end
  end

  def self.open_graph_config
    @open_graph_config ||= begin
      key = if self.config[:timeline][:use_test_app] then :test_app else :app end
      self.config[key][:open_graph]
    end
  end

  def self.credentials app = :app
    {id: self.config[app][:id], secret: self.config[app][:secret]}
  end

  def self.timeline_app_credentials
    @timeline_app_credentials ||= begin
      key = if self.config[:timeline][:use_test_app] then :test_app else :app end
      self.credentials key
    end
  end

  def self.page_tab_app_credentials
    @page_tab_app_credentials ||= begin
      key = if self.config[:page_tab][:use_test_app] then :test_app else :app end
      self.credentials key
    end
  end

  def stylesheet?
    true
  end

  def js_files
    ['fb_app.js'].map{ |j| "javascripts/#{j}" }
  end

  def head_ending
    return unless FbAppPlugin.config.present?
    lambda do
      tag 'meta', property: 'fb:app_id', content: FbAppPlugin.config[:app][:id]
    end
  end

  def control_panel_buttons
    return unless FbAppPlugin.config.present?
    return unless %w[brauliobo dtygel rosanak viniciuscb facebook_tester].include? user.identifier
    { title: self.class.plugin_name, icon: 'fb-app', url: {controller: :fb_app_plugin_myprofile} }
  end

end

ActiveSupport.on_load :open_graph_plugin do
  publisher = FbAppPlugin::Publisher.new
  OpenGraphPlugin::Stories.register_publisher publisher
end

# workaround for plugins' scope problem
require_dependency 'fb_app_plugin/display_helper'
FbAppPlugin::FbAppDisplayHelper = FbAppPlugin::DisplayHelper


