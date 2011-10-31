class DistributionPluginNodeController < DistributionPluginMyprofileController

  no_design_blocks

  def index
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

end
