class OrdersCyclePluginAdminOrderController < OrdersPluginOrderController

  def create

    @cycle = profile.orders_cycles.find params[:order][:cycle_id]
    @order = OrdersCyclePlugin::Sale.new

    if params[:order][:registered] == "true"
      if params[:order][:profile_id].nil?
        render js: "alert('"+t("views.admin.new_order.supply_profile_id")+"')"
        return
      end
      @consumer = Profile.find params[:order][:profile_id]
    else
      if params[:order][:consumer_data][:name].blank?
        render js: "alert('"+t("views.admin.new_order.supply_name")+"')"
        return
      end
      if params[:order][:consumer_data][:email].blank?
        render js: "alert('"+t("views.admin.new_order.supply_email")+"')"
        return
      end
      @consumer = user
    end

    @order.profile = profile
    @order.consumer = @consumer
    @order.cycle = @cycle
    @order.status = OrdersCyclePlugin::Cycle::SaleStatusMap[@cycle.status]
    @order.save!
    if params[:order][:registered] == "false"
      @order.consumer_data = params[:order][:consumer_data]
      @order.save!
    end
  end
end

