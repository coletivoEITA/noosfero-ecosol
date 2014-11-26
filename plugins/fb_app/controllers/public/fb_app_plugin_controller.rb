class FbAppPluginController < PublicController

  no_design_blocks

  def index
  end

  def myprofile_config
    return unless user
    redirect_to controller: :fb_app_plugin_myprofile, profile: user.identifier
  end

  protected

end
