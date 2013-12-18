# workaround for plugin class scope problem
require_dependency 'orders_cycle_plugin/display_helper'
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

class ConsumersCoopPluginMyprofileController < MyProfileController

  include ConsumersCoopPlugin::ControllerHelper

  helper ConsumersCoopPlugin::TranslationHelper
  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  def index
    if profile.has_admin? user
      redirect_to :controller => :consumers_coop_plugin_cycle, :action => :index
    else
      redirect_to :controller => :consumers_coop_plugin_order, :action => :index
    end
  end

  def settings
    if params[:commit]
      params[:profile_data][:consumers_coop_settings][:enabled] = params[:profile_data][:consumers_coop_settings][:enabled] == 'true' rescue

      was_enabled = profile.consumers_coop_settings.enabled

      params[:profile_data].delete(:consumers_coop_settings).each do |attr, value|
        profile.consumers_coop_settings.send "#{attr}=", value
      end
      profile.update_attributes! params[:profile_data]
      profile.consumers_coop_header_image_save

      if !was_enabled and profile.consumers_coop_settings.enabled
        profile.consumers_coop_enable
      elsif was_enabled
        profile.consumers_coop_disable
      end

      session[:notice] = t('consumers_coop_plugin.controllers.myprofile.distribution_settings')
      redirect_to profile_url if profile.consumers_coop_settings.enabled?
    end
  end

  protected

  def content_classes
    return "consumers-coop" if params[:action] == 'settings'
    super
  end

end
