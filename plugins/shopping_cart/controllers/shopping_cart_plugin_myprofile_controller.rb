class ShoppingCartPluginMyprofileController < MyProfileController
  def edit
    params[:settings] = treat_cart_options(params[:settings])

    @settings = profile.shopping_cart_settings params[:settings]
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

  def reports
    utc_string = ' 00:00:00 UTC'
    @from = params[:from] ? Time.parse(params[:from] + utc_string) : Time.now.utc.at_beginning_of_month
    @to = params[:to] ? Time.parse(params[:to] + utc_string) : Time.now.utc
    @status = params[:filter_status].present? ? params[:filter_status] : nil

    condition = 'created_at >= ? AND created_at <= ?'
    condition_parameters = [@from, @to+1.day]
    if @status
      condition += ' AND status = ?'
      condition_parameters << @status
    end

    conditions = [condition] + condition_parameters
    @orders = profile.orders.find(:all, :conditions => conditions)

    @products = {}
    @orders.each do |order|
      order.products_list.each do |id, qp|
        @products[id] ||= ShoppingCartPlugin::LineItem.new(id, qp[:name])
        @products[id].quantity += qp[:quantity]
      end
    end
  end

  def update_order_status
    order = OrdersPlugin::Sale.find(params[:order_id].to_i)
    order.status = params[:order_status]
    order.save!
    redirect_to :action => 'reports', :from => params[:context_from], :to => params[:context_to], :filter_status => params[:context_status]
  end

  private

  def treat_cart_options(settings)
    return if settings.blank?
    settings[:enabled] = settings[:enabled] == '1'
    settings[:delivery] = settings[:delivery] == '1'
    settings
  end

end
