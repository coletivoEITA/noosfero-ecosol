class OauthPluginAdminProvidersController < AdminController

  def new
    @provider = environment.oauth_providers.create params[:provider]
    @provider = nil if @provider.valid?
    render :layout => false
  end

  def edit
    @provider = environment.oauth_providers.find params[:id]
    @provider.update_attributes params[:provider]
    render :layout => false
  end

  def destroy
    @provider = environment.oauth_providers.find params[:id]
    @provider.destroy
    render :layout => false
  end

end
