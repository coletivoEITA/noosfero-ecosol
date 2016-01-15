class CurrencyPluginMyprofileController < MyProfileController

  before_filter :load_enterprise_currency, :only => [:edit, :disassociate, :enterprise_currency]

  def index
    @organized_currencies = profile.organized_currencies
    @accepted_currencies = profile.accepted_currencies
  end

  def create
    @currency = CurrencyPlugin::Currency.new :environment => environment
    @enterprise_currency = CurrencyPlugin::EnterpriseCurrency.new :enterprise => profile, :is_organizer => true
    if request.post?
      @error = !ActiveRecord::Base.transaction do
        @currency.update_attributes! params[:currency]
        @enterprise_currency.currency = @currency
        @enterprise_currency.save
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
    if request.post?
      @currency.update_attributes! params[:currency]
      redirect_to :action => :index
    else
      render :layout => false
    end
  end

  def disassociate
    if request.post?
      if params[:keep_acceptance] == '1'
        @enterprise_currency.update_attribute :is_organizer, false
      else
        @enterprise_currency.destroy
      end

      @enterprises = environment.enterprises.all :conditions => {:id => params[:enterprises]}, :include => :enterprise_currencies
      @enterprises.each do |enterprise|
        enterprise_currency = enterprise.enterprise_currencies.find_by_currency_id @currency.id
        enterprise_currency ||= enterprise.enterprise_currencies.build :currency => @currency
        enterprise_currency.is_organizer = true
        enterprise_currency.save
      end

      redirect_to :action => :index
    else
      @results = []
      render :layout => false
    end
  end

  def enterprise_search
    @query = params[:query].to_s.downcase
    @results = environment.enterprises.visible.all :limit => 10, :conditions => ['LOWER(name) ~ ?', @query]
    @results = @results - [@profile]
    render :partial => 'enterprise_results'
  end

  def accept
    if request.post?
      @currency = CurrencyPlugin::Currency.find params[:id]
      profile.accepted_currencies << @currency
      redirect_to :action => :index
    else
      @currencies = @profile.other_currencies.first 10
      render :layout => false
    end
  end

  def accept_search
    query = params[:query].to_s.strip.downcase
    options = {:limit => 10, :conditions => [
      'LOWER(name) ~ ? OR LOWER(symbol) ~ ? OR LOWER(description) ~ ?',
      query, query, query
    ]}
    @currencies = CurrencyPlugin::Currency.all options
    @currencies = @currencies - profile.currencies
    render :partial => 'accept_form'
  end

  def stop_accepting
    @ce = profile.enterprise_currencies.first :conditions => {:currency_id => params[:id]}
    @currency = @ce.currency
    @ce.destroy
  end

  protected

  def load_enterprise_currency
    @enterprise_currency = @profile.enterprise_currencies.find_by_currency_id params[:id]
    @currency = @enterprise_currency.currency
    raise "Enterprise isn't an organizer of this currency" unless @enterprise_currency.is_organizer
  end

end
