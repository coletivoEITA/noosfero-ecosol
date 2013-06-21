class CurrencyPluginMyprofileController < MyProfileController

  def index
    @organized_currencies = profile.organized_currencies
    @accepted_currencies = profile.accepted_currencies
  end

  def create
    @currency = CurrencyPlugin::Currency.new :environment => environment
    @acceptance = CurrencyPlugin::EnterpriseCurrency.new :enterprise => profile, :is_organizer => true
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

  def disassociate
  end

  def accept
    if request.post?
      @currencies = CurrencyPlugin::Currency.find params[:id]
      profile.accepted_currencies << @currencies
      redirect_to :action => :index
    else
      @currencies = []
      render :layout => false
    end
  end

  def accept_search
    query = params[:query].strip.downcase
    options = {:limit => 10, :conditions => [
      'LOWER(name) ~ ? OR LOWER(symbol) ~ ? OR LOWER(description) ~ ?',
      query, query, query
    ]}
    @currencies = CurrencyPlugin::Currency.all(options)
    @currencies = @currencies - profile.currencies
    render :partial => 'accept_form'
  end

  def stop_accepting
    @ce = profile.enterprise_currencies.first :conditions => {:currency_id => params[:id]}
    @currency = @ce.currency
    @ce.destroy
  end

  protected

end
