class DistributionPluginNodeController < DistributionPluginMyprofileController

  before_filter :set_admin_action, :only => [:index]

  def index
    if @node.profile.admins.include? @user_node.profile
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
      @node.update_attributes! params[:node]
      session[:notice] = _('Distribution settings saved.')

      unless @node.profile.blocks.collect{ |b| b.class.name }.include?("DistributionPlugin::OrderBlock")
        boxes = @node.profile.boxes.select{ |box| !box.blocks.collect{ |b| b.class.name }.include?("MainBlock") }
        box = boxes.count > 1 ? boxes.max{ |a,b| a.position <=> b.position } : Box.create(:owner => @node.profile, :position => 3)

        block = DistributionPlugin::OrderBlock.create! :box => box
        block.move_to_top
      end

      link = url_for :controller => :distribution_plugin_node, :action => :index, :profile => @node.profile.identifier, :only_path => true
      link_list = @node.profile.blocks.select{ |b| b.class.name == 'LinkListBlock' }.first
      if link_list and not link_list.links.map{ |l| l[:address] }.include?(link)
        link_list.links = [{:name => _("Consumers' Collective"), :address => link, :icon => 'nil'}] + link_list.links
        link_list.save!
      end
    end
  end

  protected

  def content_classes
    return "plugin-distribution" if params[:action] == 'settings'
    super
  end

end
