class DistributionPluginNodeController < DistributionPluginMyprofileController

  before_filter :set_admin_action, :only => [:index]

  def index
    redirect_to :controller => :distribution_plugin_session, :action => :index
    #self.class.no_design_blocks
    #@suppliers = @node.suppliers - [@node.self_supplier]
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
      @node.update_attributes! params[:node]
      session[:notice] = _('Distribution settings saved.')

      unless @node.profile.blocks.collect{ |b| b.class.name }.include?("DistributionPlugin::OrderBlock")
        boxes = @node.profile.boxes.select{ |box| !box.blocks.collect{ |b| b.class.name }.include?("MainBlock") }
        box = boxes.count > 1 ? boxes.max{ |a,b| a.position <=> b.position } : Box.create(:owner => @node.profile, :position => 3)

        block = DistributionPlugin::OrderBlock.create! :box => box
        block.move_to_top
      end
    end
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
