class ShoppingCartPluginMyprofileController < MyProfileController

  helper DeliveryPlugin::DisplayHelper

  def edit
    params[:settings] = treat_cart_options(params[:settings])

    @settings = profile.shopping_cart_settings params[:settings] || {}
    if request.post?
      begin
        @settings.save!
        session[:notice] = _('Option updated successfully.')
      rescue Exception => exception
        session[:notice] = _('Option wasn\'t updated successfully.')
      end
      redirect_to :action => 'edit'
    end
  end

  protected

  def treat_cart_options(settings)
    return if settings.blank?
    settings[:enabled] = settings[:enabled] == '1'
    settings[:delivery] = settings[:delivery] == '1'
    settings
  end

end
