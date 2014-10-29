class FbAppPluginMyprofileController < MyProfileController

  no_design_blocks

  def index

  end

  def save_auth
    @client = FbAppPlugin.oauth_client_for environment
    @auth = FbAppPlugin::Auth.where(profile_id: user.id, client_id: @client.id).first
    @auth ||= FbAppPlugin::Auth.new profile_id: user.id, client_id: @client.id
    @auth.attributes = params[:auth]
    @auth.save! if @auth.changed?

    render nothing: true
  end

  protected

end
