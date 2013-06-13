class CurrencyPluginMyprofileController < MyProfileController

  def index
  end

  def create
    @currency = CurrencyPlugin::Currency.new
    render :layout => false
  end

  def accept
    render :layout => false
  end

end
