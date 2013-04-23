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
        if params[:sendmail]
          DistributionPlugin::Mailer.delay(:run_at => @session.start).deliver_open_session @session.node,
            @session,_('New open cycle: ')+@session.name, @session.opening_message
        end
        render :partial => 'new'
      else
        render :partial => 'edit'
      end
    else
      count = DistributionPluginSession.count :conditions => {:node_id => @node}
      @session = DistributionPluginSession.create! :node => @node, :status => 'new', :name => _("Cycle n.%{n}") % {:n => count+1}
    end
  end

  def edit
    @session = DistributionPluginSession.find params[:id]
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

  def step_back
    @session = DistributionPluginSession.find params[:id]
    @session.step_back
    @session.save!
    redirect_to :action => 'edit', :id => @session.id
  end

  def add_products
    @session = DistributionPluginSession.find params[:id]
    @missing_products = @node.products.unarchived.distributed.active - @session.from_products.unarchived
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
    send_file report_file, :type => 'application/xlsx',
      :disposition => 'attachment',
      :filename => _("Products Report - %{date} - %{profile_identifier} - %{cycle_number} - %{cycle_name}.xlsx") % {
        :date => DateTime.now.strftime("%Y-%m-%d"), :profile_identifier => profile.identifier, :cycle_number => @session.code, :cycle_name => @session.name}
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
    send_file report_file, :type => 'application/xlsx',
      :disposition => 'attachment',
      :filename => _("Cycle Orders Report - %{date} - %{profile_identifier} - %{cycle_number} - %{cycle_name}.xlsx") % {:date => DateTime.now.strftime("%Y-%m-%d"), :profile_identifier => profile.identifier, :cycle_number => @session.code, :cycle_name => @session.name}
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

end
