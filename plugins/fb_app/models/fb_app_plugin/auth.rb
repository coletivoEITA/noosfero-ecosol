class FbAppPlugin::Auth < OauthPlugin::Auth

  settings_items :signed_request
  settings_items :user_id
  attr_accessible :user_id, :signed_request

end

