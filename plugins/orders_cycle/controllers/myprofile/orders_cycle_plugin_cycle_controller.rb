class OrdersCyclePluginCycleController < MyProfileController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  protect 'edit_profile', :profile
  before_filter :set_admin

  helper OrdersCyclePlugin::TranslationHelper
  helper OrdersCyclePlugin::CycleHelper

  def index
    @closed_cycles = search_scope(profile.orders_cycles.status_closed).all
    if request.xhr?
      render :partial => 'results'
    else
      @open_cycles = profile.orders_cycles.status_open
    end
  end

  def new
    if request.post?
      @cycle = OrdersCyclePlugin::Cycle.find params[:id]
      @success = @cycle.update_attributes params[:cycle]
      if @success
        session[:notice] = t('controllers.myprofile.cycle_controller.cycle_created')
        if params[:sendmail]
          OrdersCyclePlugin::Mailer.delay(:run_at => @cycle.start).deliver_open_cycle @cycle.profile,
            @cycle,t('controllers.myprofile.cycle_controller.new_open_cycle')+": "+@cycle.name, @cycle.opening_message
        end
        render :partial => 'new'
      else
        render :partial => 'edit'
      end
    else
      count = OrdersCyclePlugin::Cycle.count :conditions => {:profile_id => profile}
      @cycle = OrdersCyclePlugin::Cycle.create! :profile => profile, :status => 'new',
        :name => t('controllers.myprofile.cycle_controller.cycle_n_n') % {:n => count+1}
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
            @cycle,t('controllers.myprofile.cycle_controller.new_open_cycle')+": "+@cycle.name, @cycle.opening_message
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
    redirect_to :action => :index
  end

  def step
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    @cycle.step
    @cycle.save!
    redirect_to :action => :edit, :id => @cycle.id
  end

  def step_back
    @cycle = OrdersCyclePlugin::Cycle.find params[:id]
    @cycle.step_back
    @cycle.save!
    redirect_to :action => 'edit', :id => @cycle.id
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
      :filename => t('controllers.myprofile.cycle_controller.products_report_date_') % {
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
      :filename => t('controllers.myprofile.cycle_controller.cycle_orders_report_d') % {:date => DateTime.now.strftime("%Y-%m-%d"), :profile_identifier => profile.identifier, :cycle_number => @cycle.code, :cycle_name => @cycle.name}
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

  def orders_filter
  end

  protected

  def search_scope scope
    params[:date] ||= {}
    scope = scope.by_year params[:date][:year] if params[:date][:year].present?
    scope = scope.by_month params[:date][:month] if params[:date][:month].present?
    scope = scope.by_status params[:status] if params[:status].present?
    scope
  end

  def set_admin
    @admin = true
  end

end
