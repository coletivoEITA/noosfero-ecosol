class ConsumersCoopPluginMyprofileController < MyProfileController

  include ConsumersCoopPlugin::ControllerHelper

  before_filter :set_admin_action, :only => [:index]

  def index
    if profile.has_admin? user
      redirect_to :controller => :orders_cycle_plugin_cycle, :action => :index
    else
      redirect_to :controller => :orders_cycle_plugin_order, :action => :index
    end
  end

  def settings
    if params[:commit]
      was_enabled = profile.consumers_coop_settings.enabled?

      @profile.update_attributes! params[:profile_data]
      profile.consumers_coop_header_image_save

      if !was_enabled and profile.consumers_coop_settings.enabled?
        profile.consumers_coop_enable
      elsif was_enabled
        profile.consumers_coop_disable
      end

      session[:notice] = t('consumers_coop_plugin.controllers.myprofile.profile_controller.distribution_settings')
      redirect_to profile_url if profile.consumers_coop_settings.enabled?
    end
  end

  protected

  def content_classes
    return "consumers-coop" if params[:action] == 'settings'
    super
  end

end
