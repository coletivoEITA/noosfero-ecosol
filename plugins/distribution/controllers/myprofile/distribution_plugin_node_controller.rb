class DistributionPluginNodeController < DistributionPluginMyprofileController

  before_filter :set_admin_action, :only => [:index]

  def index
    if @node.has_admin? @user_node
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
      if params[:apply_to_all]
        @node.default_products_margins
      end
      render :partial => 'distribution_plugin_shared/pagereload'
    else
      render :layout => false
    end
  end

  def settings
    if params[:commit]
      was_enabled = @node.enabled?
      @node.update_attributes! params[:node]
      session[:notice] = _('Distribution settings saved.')

      if !was_enabled and @node.enabled?
        @node.enable_collective_view
      elsif was_enabled
        @node.disable_collective_view
      end
    end
  end

  protected

  def content_classes
    return "plugin-distribution" if params[:action] == 'settings'
    super
  end

end
