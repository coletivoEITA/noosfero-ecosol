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

  def self.test_users
    @test_users = self.config[:test_users]
  end
  def self.test_user? user
    #dtygel commented that to allow the plugin to be available to everybody.
    #self.test_users.blank? or self.test_users.include? user.identifier
    user.identifier
  end

  def self.scope user
    if self.test_user? user then 'publish_actions' else '' end
  end

  def self.oauth_provider_for environment
    return unless self.config.present?

    @oauth_providers ||= {}
    @oauth_providers[environment] ||= begin
      app_id = self.timeline_app_credentials[:id].to_s
      app_secret = self.timeline_app_credentials[:secret].to_s

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
    return unless self.config.present?

    @open_graph_config ||= begin
      key = if self.config[:timeline][:use_test_app] then :test_app else :app end
      self.config[key][:open_graph]
    end
  end

  def self.credentials app = :app
    return unless self.config.present?
    {id: self.config[app][:id], secret: self.config[app][:secret]}
  end

  def self.timeline_app_credentials
    return unless self.config.present?
    @timeline_app_credentials ||= begin
      key = if self.config[:timeline][:use_test_app] then :test_app else :app end
      self.credentials key
    end
  end

  def self.page_tab_app_credentials
    return unless self.config.present?
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
    { title: self.class.plugin_name, icon: 'fb-app', url: {host: FbAppPlugin.config[:app][:domain], profile: profile.identifier, controller: :fb_app_plugin_myprofile} }
  end

end

ActiveSupport.on_load :open_graph_plugin do
  publisher = FbAppPlugin::Publisher.new
  OpenGraphPlugin::Stories.register_publisher publisher
  MetadataPlugin::Spec::Controllers[:fb_app_plugin_page_tab] = {
    variable: :@product,
  }
end

# workaround for plugins' scope problem
require_dependency 'fb_app_plugin/display_helper'
FbAppPlugin::FbAppDisplayHelper = FbAppPlugin::DisplayHelper


