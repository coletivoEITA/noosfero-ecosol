class CurrencyPluginMyprofileController < MyProfileController

  def index
    @currencies = profile.organized_currencies
  end

  def create
    @currency = CurrencyPlugin::Currency.new :environment => environment
    @acceptance = CurrencyPlugin::CurrencyEnterprise.new :enterprise => profile, :is_organizer => true
    if request.post?
      @error = !ActiveRecord::Base.transaction do
        @currency.update_attributes! params[:currency]
        @acceptance.currency = @currency
        @acceptance.save
      end

      if @error
      else
        redirect_to :action => :index
      end
    else
      render :layout => false
    end
  end

  def edit
    @currency = CurrencyPlugin::Currency.find params[:id]
    if request.post?
      @currency.update_attributes! params[:currency]
      redirect_to :action => :index
    else
      render :layout => false
    end
  end

  def accept
    render :layout => false
  end

end
