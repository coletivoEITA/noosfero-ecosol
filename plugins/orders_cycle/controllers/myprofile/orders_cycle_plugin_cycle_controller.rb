class OrdersCyclePluginCycleController < MyProfileController

  no_design_blocks

  helper OrdersCyclePlugin::CycleHelper

  def index
    @cycles = profile.orders_cycles
    params[:date] ||= {}
    year = params[:date][:year]
    month = params[:date][:month]
    @year_date = year.blank? ? Date.today : Time.mktime(year).to_date
    @month_date = month.blank? ? Date.today : Time.mktime(year, month).to_date
    if request.xhr?
      render :partial => 'results'
    end
  end

  def new
    if request.post?
      @cycle = OrdersCyclePlugin::Cycle.find params[:id]
      @success = @cycle.update_attributes params[:cycle]
      if @success
        session[:notice] = t('orders_cycle_plugin.controllers.myprofile.cycle_controller.cycle_created')
        if params[:sendmail]
          OrdersCyclePlugin::Mailer.delay(:run_at => @cycle.start).deliver_open_cycle @cycle.profile,
            @cycle,t('orders_cycle_plugin.controllers.myprofile.cycle_controller.new_open_cycle')+": "+@cycle.name, @cycle.opening_message
        end
        render :partial => 'new'
      else
        render :partial => 'edit'
      end
    else
      count = OrdersCyclePlugin::Cycle.count :conditions => {:profile_id => profile}
      @cycle = OrdersCyclePlugin::Cycle.create! :profile => :profile, :status => 'new', :name => t('orders_cycle_plugin.controllers.myprofile.cycle_controller.cycle_n_n') % {:n => count+1}
    end
  end

  def edit
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    @products = (@cycle.products.unarchived.paginate(:per_page => 15, :page => params["page"]))

    if request.xhr?
      if params[:commit]
        @success = @cycle.update_attributes params[:cycle]
        if params[:sendmail]
          OrdersCyclePlugin::Mailer.delay(:run_at => @cycle.start).deliver_open_cycle @cycle.profile,
            @cycle,t('orders_cycle_plugin.controllers.myprofile.cycle_controller.new_open_cycle')+": "+@cycle.name, @cycle.opening_message
        end
        render :partial => 'edit'
      else
        render :update do |page|
          page.replace_html "cycle-product-lines", :partial => "product_lines"
        end
      end
    end
  end

  def destroy
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    @cycle.destroy
    render :nothing => true
  end

  def step
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    @cycle.step
    @cycle.save!
    redirect_to :action => 'edit', :id => @cycle.id
  end

  def step_back
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    @cycle.step_back
    @cycle.save!
    redirect_to :action => 'edit', :id => @cycle.id
  end

  def add_products
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    @missing_products = profile.products.unarchived.distributed.available - @cycle.from_products.unarchived
    if params[:products_id]
      params[:products_id].each do |id|
        product = SuppliersPlugin::DistributedProduct.find id
        OrdersCyclePlugin::OfferedProduct.create_from_distributed @cycle, product
      end
      render :partial => 'suppliers_plugin_shared/pagereload'
    else
      render :layout => false
    end
  end

  def add_missing_products
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    @cycle.add_distributed_products
    render :partial => 'suppliers_plugin_shared/pagereload'
  end

  def report_products
    extend OrdersCyclePlugin::Report::ClassMethods
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    tmp_dir, report_file = report_products_by_supplier @cycle
    if report_file.nil?
      return false
    end
    send_file report_file, :type => 'application/xlsx',
      :disposition => 'attachment',
      :filename => t('orders_cycle_plugin.controllers.myprofile.cycle_controller.products_report_date_') % {
        :date => DateTime.now.strftime("%Y-%m-%d"), :profile_identifier => profile.identifier, :cycle_number => @cycle.code, :cycle_name => @cycle.name}
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

  def report_orders
    extend OrdersCyclePlugin::Report::ClassMethods
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    tmp_dir, report_file = report_orders_by_consumer @cycle
    if report_file.nil?
      render :nothing => true, :status => :ok
      return
    end
    send_file report_file, :type => 'application/xlsx',
      :disposition => 'attachment',
      :filename => t('orders_cycle_plugin.controllers.myprofile.cycle_controller.cycle_orders_report_d') % {:date => DateTime.now.strftime("%Y-%m-%d"), :profile_identifier => profile.identifier, :cycle_number => @cycle.code, :cycle_name => @cycle.name}
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

end
