require_dependency 'profile'

# attr_accessible must be defined on subclasses
Profile.descendants.each do |subclass|
  subclass.class_eval do
    attr_accessible :fb_app_settings
  end
end

class Profile

  def fb_app_settings attrs = {}
    @fb_app_settings ||= FbAppPlugin::Settings.new self, FbAppPlugin, attrs
  end
  alias_method :fb_app_settings=, :fb_app_settings

  has_many :fb_app_page_tabs, class_name: 'FbAppPlugin::PageTab'

  def fb_app_auth
    provider = FbAppPlugin.oauth_provider_for self.environment
    self.oauth_provider_auths.where(provider_id: provider.id).first
  end

end
