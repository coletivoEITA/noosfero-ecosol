require_dependency 'profile'

class Profile

  has_one :fb_app_timeline_config, class_name: 'FbAppPlugin::TimelineConfig'
  has_many :fb_app_page_tag_configs, class_name: 'FbAppPlugin::PageTabConfig'

  auto_build :fb_app_timeline_config

  def fb_app_auth
    provider = FbAppPlugin.oauth_provider_for self.environment
    self.oauth_auths.where(provider_id: provider.id).first
  end

end
