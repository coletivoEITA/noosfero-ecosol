class FbAppPluginController < PublicController

  no_design_blocks

  def index
  end

  def myprofile_config
    if logged_in?
      redirect_to controller: :fb_app_plugin_myprofile, profile: user.identifier
    else
      redirect_to controller: :account, action: :login, return_to: url_for(controller: :fb_app_plugin, action: :myprofile_config)
    end
  end

  protected

end
