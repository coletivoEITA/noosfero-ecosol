require_dependency 'profile'

class Profile

  has_many :fb_app_page_tag_configs, class_name: 'FbAppPlugin::PageTabConfig'

  def fb_app_auth
    provider = FbAppPlugin.oauth_provider_for self.environment
    self.oauth_provider_auths.where(provider_id: provider.id).first
  end

end
