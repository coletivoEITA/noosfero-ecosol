class ConsumersCoopPluginNodeController < ConsumersCoopPluginMyprofileController

  before_filter :set_admin_action, :only => [:index]

  def index
    if profile.has_admin? user
      redirect_to :controller => :consumers_coop_plugin_cycle, :action => :index
    else
      redirect_to :controller => :consumers_coop_plugin_order, :action => :index
    end
  end

  def edit
    @node.update_attributes params[:node]
    render :nothing => true
  end

  def settings
    if params[:commit]
      was_enabled = @node.enabled?
      @node.update_attributes! params[:node]
      session[:notice] = t('consumers_coop_plugin.controllers.myprofile.node_controller.distribution_settings')

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
    return "consumers-coop" if params[:action] == 'settings'
    super
  end

end
