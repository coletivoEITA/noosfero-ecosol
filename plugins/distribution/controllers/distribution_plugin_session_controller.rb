class DistributionPluginSessionController < DistributionPluginMyprofileController

  no_design_blocks

  helper DistributionPlugin::SessionHelper

  before_filter :set_admin_action

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
      @session = DistributionPluginSession.find params[:id]
      @success = @session.update_attributes params[:session]
      if @success
        session[:notice] = _('Cycle created')
        render :partial => 'new'
      else
        render :partial => 'edit'
      end
    else 
      @session = DistributionPluginSession.create! :node => @node, :status => 'new'
    end
  end

  def edit
    @session = DistributionPluginSession.find params[:id]
    if request.xhr?
      @success = @session.update_attributes params[:session]
      render :partial => 'edit'
    end
  end

  def destroy
    @session = DistributionPluginSession.find params[:id]
    @session.destroy
    render :nothing => true
  end

  def step
    @session = DistributionPluginSession.find params[:id]
    @session.step
    @session.save!
    redirect_to :action => 'edit', :id => @session.id
  end

  def add_products
    @session = DistributionPluginSession.find params[:id]
    @missing_products = @node.products.unarchived.distributed - @session.from_products.unarchived
    if params[:products_id]
      params[:products_id].each do |id|
        product = DistributionPluginDistributedProduct.find id
        DistributionPluginSessionProduct.create_from_distributed @session, product
      end
      render :partial => 'distribution_plugin_shared/pagereload'
    else
      render :layout => false
    end
  end

  def add_missing_products
    @session = DistributionPluginSession.find params[:id]
    @session.add_distributed_products
    render :partial => 'distribution_plugin_shared/pagereload'
  end

  def report_products
    extend DistributionPlugin::Report::ClassMethods
    @session = DistributionPluginSession.find params[:id]
    tmp_dir, report_file = report_products_by_supplier @session
    if report_file.nil?
      return false
    end
    send_file report_file, :type => 'application/ods',
      :disposition => 'attachment',
      :filename => _("Products Report.ods")
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

  def report_orders
    extend DistributionPlugin::Report::ClassMethods
    @session = DistributionPluginSession.find params[:id]
    tmp_dir, report_file = report_orders_by_consumer @session
    if report_file.nil?
      render :nothing => true, :status => :ok
      return
    end
    send_file report_file, :type => 'application/ods',
      :disposition => 'attachment',
      :filename => _("Cycle Orders Report.ods")
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

end
