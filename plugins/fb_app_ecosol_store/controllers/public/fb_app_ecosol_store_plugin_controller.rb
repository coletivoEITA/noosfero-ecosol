class FbAppEcosolStorePluginController < PublicController

  before_filter :change_layout

  def index
    load_config

    if params[:tabs_added]
      @signed_requests = {}; params[:tabs_added].each_with_index{ |(id, value), i| @signed_requests[i] = id }
      render :action => 'tabs_added'
    elsif @config
      if @config.profiles.present?
        if @profiles

        @current_theme = 'template'
        extend CatalogHelper
        catalog_load_index

        @change_layout = false
        render :template => 'catalog/index'
      else
      end
    else
      redirect_to :action => 'admin'
    end
  end

  def admin
    load_config || create_config
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
    @config
  end

  def create_config
    @config ||= FbAppEcosolStorePlugin::SignedRequestConfig.create! :signed_request => params[:signed_request]
  end

  def get_layout
    return super unless @change_layout
    'fb_app_ecosol_store_plugin_layouts/default'
  end

  def change_layout
    @change_layout = true
  end

  def profile
    @profile
  end

  def body_classes_with_facebook
    raise 'here'
    "#{body_classes_without_facebook} facebook-app"
  end
  alias_method_chain :body_classes, :facebook

end
