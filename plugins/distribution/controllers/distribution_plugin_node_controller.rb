class DistributionPluginNodeController < DistributionPluginMyprofileController

  before_filter :set_admin_action, :only => [:index]

  def index
    self.class.no_design_blocks
    @suppliers = @node.suppliers - [@node.self_supplier]
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
    return super if params[:action] != 'settings'
  end
  def custom_layout?
    return super if params[:action] != 'settings'
    false
  end

end
