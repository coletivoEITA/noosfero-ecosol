class OauthPluginAdminAppsController < AdminController

  def new
    @app = environment.oauth_apps.create params[:app]
    @app = nil if @app.valid?
    render :layout => false
  end

  def edit
    @app = environment.oauth_apps.find params[:id]
    @app.update_attributes params[:app]
    render :layout => false
  end

  def destroy
    @app = environment.oauth_apps.find params[:id]
    @app.destroy
    render :layout => false
  end

end
