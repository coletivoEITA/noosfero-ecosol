class DistributionPluginSessionController < DistributionPluginMyprofileController

  no_design_blocks
  before_filter :set_admin_action

  helper DistributionPlugin::SessionHelper

  def index
    @sessions = @node.sessions
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
      @session = DistributionPlugin::Session.find params[:id]
      @success = @session.update_attributes params[:session]
      if @success
        session[:notice] = t('distribution_plugin.controllers.myprofile.session_controller.cycle_created')
        if params[:sendmail]
          DistributionPlugin::Mailer.delay(:run_at => @session.start).deliver_open_session @session.node,
            @session,t('distribution_plugin.controllers.myprofile.session_controller.new_open_cycle')+@session.name, @session.opening_message
        end
        render :partial => 'new'
      else
        render :partial => 'edit'
      end
    else
      count = DistributionPlugin::Session.count :conditions => {:node_id => @node}
      @session = DistributionPlugin::Session.create! :node => @node, :status => 'new', :name => t('distribution_plugin.controllers.myprofile.session_controller.cycle_n_n') % {:n => count+1}
    end
  end

  def edit
    @session = DistributionPlugin::Session.find params[:id]
    @products = (@session.products.unarchived.paginate(:per_page => 15, :page => params["page"]))

    if request.xhr?
      if params[:commit]
        @success = @session.update_attributes params[:session]
        render :partial => 'edit'
      else
        render :update do |page|
          page.replace_html "session-product-lines", :partial => "product_lines"
        end
      end
    end
  end

  def destroy
    @session = DistributionPlugin::Session.find params[:id]
    @session.destroy
    render :nothing => true
  end

  def step
    @session = DistributionPlugin::Session.find params[:id]
    @session.step
    @session.save!
    redirect_to :action => 'edit', :id => @session.id
  end

  def step_back
    @session = DistributionPlugin::Session.find params[:id]
    @session.step_back
    @session.save!
    redirect_to :action => 'edit', :id => @session.id
  end

  def add_products
    @session = DistributionPlugin::Session.find params[:id]
    @missing_products = @node.products.unarchived.distributed.available - @session.from_products.unarchived
    if params[:products_id]
      params[:products_id].each do |id|
        product = SuppliersPlugin::DistributedProduct.find id
        DistributionPlugin::OfferedProduct.create_from_distributed @session, product
      end
      render :partial => 'distribution_plugin_shared/pagereload'
    else
      render :layout => false
    end
  end

  def add_missing_products
    @session = DistributionPlugin::Session.find params[:id]
    @session.add_distributed_products
    render :partial => 'distribution_plugin_shared/pagereload'
  end

  def report_products
    extend DistributionPlugin::Report::ClassMethods
    @session = DistributionPlugin::Session.find params[:id]
    tmp_dir, report_file = report_products_by_supplier @session
    if report_file.nil?
      return false
    end
    send_file report_file, :type => 'application/xlsx',
      :disposition => 'attachment',
      :filename => t('distribution_plugin.controllers.myprofile.session_controller.products_report_date_') % {
        :date => DateTime.now.strftime("%Y-%m-%d"), :profile_identifier => profile.identifier, :cycle_number => @session.code, :cycle_name => @session.name}
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

  def report_orders
    extend DistributionPlugin::Report::ClassMethods
    @session = DistributionPlugin::Session.find params[:id]
    tmp_dir, report_file = report_orders_by_consumer @session
    if report_file.nil?
      render :nothing => true, :status => :ok
      return
    end
    send_file report_file, :type => 'application/xlsx',
      :disposition => 'attachment',
      :filename => t('distribution_plugin.controllers.myprofile.session_controller.cycle_orders_report_d') % {:date => DateTime.now.strftime("%Y-%m-%d"), :profile_identifier => profile.identifier, :cycle_number => @session.code, :cycle_name => @session.name}
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

end
