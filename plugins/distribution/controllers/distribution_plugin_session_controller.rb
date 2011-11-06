class DistributionPluginSessionController < DistributionPluginMyprofileController
  no_design_blocks

  helper DistributionPlugin::SessionHelper

  before_filter :set_admin_action

  def index
    @sessions = @node.sessions
  end

  def new
    @session = DistributionPluginSession.new(:node => @node)
    @session.status = 'new'
    if request.post?
      @session.update_attributes(params[:session])
      if @session.save
        redirect_to :action => :edit, :id => @session.id
      end
    end
  end

  def step
    @session = DistributionPluginSession.find params[:id]
    @session.step
    @session.save!
    redirect_to :action => 'edit', :id => @session.id
  end

  def edit
    @session = DistributionPluginSession.find params[:id]
    if request.post?
      @session.update_attributes(params[:session])
      @session.save
      respond_to do |format| 
        format.html
        format.js { render :partial => 'edit_fields', :layout => false }
      end
    end
  end

  def report_products
    extend DistributionPlugin::Report::ClassMethods
    session = DistributionPluginSession.find params[:id]
    @ordered_products_by_suppliers = session.ordered_products_by_suppliers
    tmp_dir, report_file = report_products_by_supplier @ordered_products_by_suppliers
    if report_file.nil?
      return false
    end
    send_file report_file, :type => 'application/ods',
      :disposition => 'attachment',
      :filename => _("Products Report.ods")
    require 'fileutils'
    #FileUtils.rm_rf tmp_dir
  end

end
