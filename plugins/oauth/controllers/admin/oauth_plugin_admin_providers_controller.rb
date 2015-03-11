class OauthPluginAdminProvidersController < AdminController

  def new
    @provider = environment.oauth_providers.create params[:provider]
    @provider = nil if @provider.valid?
  end

  def edit
    @provider = environment.oauth_providers.find params[:id]
    @provider.update_attributes params[:provider]
  end

  def destroy
    @provider = environment.oauth_providers.find params[:id]
    @provider.destroy
  end

end
