class FbAppEcosolStorePluginController < PublicController

  def index
  end

  def admin
    load_config
    @profiles = @config.profiles
    if request.post?
      @config.update_attributes! params[:config]
    end
  end

  def uninstall
    render :text => params.to_yaml
  end

  def search
    @profiles = Profile.find_by_contents(params[:query])[:results]
    render :json => (@profiles.map do |profile|
      {:name => profile.name, :id => profile.id}
    end)
  end

  protected

  def load_config
    @config = FbAppEcosolStorePlugin::SignedRequestConfig.where(:signed_request => params[:signed_request]).first
    @new_request = true if @config.blank?
    @config ||= FbAppEcosolStorePlugin::SignedRequestConfig.create! :signed_request => params[:signed_request]
  end

  def get_layout
    'fb_app_ecosol_store_plugin_layouts/default'
  end

end
