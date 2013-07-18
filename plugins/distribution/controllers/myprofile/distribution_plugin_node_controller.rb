class DistributionPluginNodeController < DistributionPluginMyprofileController

  before_filter :set_admin_action, :only => [:index]

  def index
    if profile.has_admin? user
      redirect_to :controller => :distribution_plugin_session, :action => :index
    else
      redirect_to :controller => :distribution_plugin_order, :action => :index
    end
  end

  def edit
    @node.update_attributes params[:node]
    render :nothing => true
  end

  def margins_change
    if params[:commit]
      @node.update_attributes params[:node]
      @node.default_products_margins if params[:apply_to_all]
      @node.default_open_sessions_products_margins if params[:apply_to_open_sessions]
      render :partial => 'distribution_plugin_shared/pagereload'
    else
      render :layout => false
    end
  end

  def settings
    if params[:commit]
      was_enabled = @node.enabled?
      @node.update_attributes! params[:node]
      session[:notice] = t('distribution_plugin.controllers.myprofile.node_controller.distribution_settings')

      if !was_enabled and @node.enabled?
        @node.enable_collective_view
      elsif was_enabled
        @node.disable_collective_view
      end
      redirect_to profile_url if @node.enabled?
    end
  end

  protected

  def content_classes
    return "plugin-distribution" if params[:action] == 'settings'
    super
  end

end
