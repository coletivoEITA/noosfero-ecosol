class FbAppPluginMyprofileController < MyProfileController

  no_design_blocks

  def index
  end

  def save_auth
    @provider = FbAppPlugin.oauth_provider_for environment
    @auth = FbAppPlugin::Auth.where(profile_id: user.id, provider_id: @provider.id).first

    @status = params[:auth].delete :status
    if @status == 'not_authorized'
      if @auth
        @auth.destroy
        @auth = nil
      end
    elsif @status == 'connected'
      @auth ||= FbAppPlugin::Auth.new profile_id: user.id, provider_id: @provider.id
      @auth.attributes = params[:auth]
      @auth.save! if @auth.changed?
    end

    render partial: 'auth'
  end

  protected

end
