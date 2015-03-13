class ConsumersCoopPluginMyprofileController < MyProfileController

  include ConsumersCoopPlugin::ControllerHelper
  include ConsumersCoopPlugin::TranslationHelper

  helper OrdersCyclePlugin::DisplayHelper
  helper ConsumersCoopPlugin::TranslationHelper

  def index
    if profile.has_admin? user
      redirect_to controller: :consumers_coop_plugin_cycle, action: :index
    else
      redirect_to controller: :consumers_coop_plugin_order, action: :index
    end
  end

  def settings
    if params[:commit]
      params[:profile_data][:consumers_coop_settings][:enabled] = params[:profile_data][:consumers_coop_settings][:enabled] == 'true' rescue false
      params[:profile_data][:volunteers_settings][:cycle_volunteers_enabled] = params[:profile_data][:volunteers_settings][:cycle_volunteers_enabled] == '1' rescue false

      was_enabled = profile.consumers_coop_settings.enabled

      profile.update_attributes! params[:profile_data]
      profile.consumers_coop_header_image_save

      if !was_enabled and profile.consumers_coop_settings.enabled
        profile.consumers_coop_enable
      elsif was_enabled and !profile.consumers_coop_settings.enabled
        profile.consumers_coop_disable
      end

      session[:notice] = t('controllers.myprofile.distribution_settings')
    end
  end

  protected

  def content_classes
    return "consumers-coop" if params[:action] == 'settings'
    super
  end

end
