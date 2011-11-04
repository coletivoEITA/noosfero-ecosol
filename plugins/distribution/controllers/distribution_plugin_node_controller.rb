class DistributionPluginNodeController < DistributionPluginMyprofileController

  def index
    redirect_to :controller => :distribution_plugin_session, :action => :index
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

  end

  protected

  def custom_layout
  end
  def custom_layout?
    false
  end

end
