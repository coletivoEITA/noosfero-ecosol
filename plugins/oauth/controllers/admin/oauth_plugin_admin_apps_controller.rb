class OauthPluginAdminAppsController < AdminController

  def new
    @app = environment.oauth_apps.create params[:app]
    @app = nil if @app.valid?
  end

  def edit
    @app = environment.oauth_apps.find params[:id]
    @app.update_attributes params[:app]
  end

  def destroy
    @app = environment.oauth_apps.find params[:id]
    @app.destroy
  end

end
