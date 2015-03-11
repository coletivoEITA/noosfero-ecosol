class NetworksPluginNodeController < MyProfileController

  include NetworksPlugin::TranslationHelper

  before_filter :load_node, :only => [:associate]

  helper NetworksPlugin::DisplayHelper

  def associate
    @new_node = NetworksPlugin::Node.new((params[:node] || {}).merge(:environment => environment, :parent => @node))

    if params[:commit]
      @new_node.save
    else
      respond_to{ |format| format.html{ render :layout => false } }
    end
  end

  def edit
    @node = NetworksPlugin::Node.find params[:id]

    if request.put?
      @node.update_attributes params[:profile_data]
      @node.home_page.update_attributes params[:home_page]
      session[:notice] = t('controllers.node.edit')
      redirect_to :controller => :networks_plugin_network, :action => :structure, :node_id => @node.parent.id
    end
  end

  def destroy
    @node = NetworksPlugin::Node.find params[:id]
    @node.destroy

    @node.parent.reload
    @node = @node.parent
  end

  def orders_management
    @node = NetworksPlugin::Node.find params[:id]
    @managers = environment.people.find params[:orders_managers].to_a
    @role = Profile::Roles.orders_manager environment

    @node.networks_settings.orders_forward = params[:orders_forward]
    @node.save

    @node.role_assignments.where(:role_id => @role.id).each{ |ra| ra.destroy }
    @managers.each do |manager|
      RoleAssignment.create! :role => @role, :resource => @node, :accessor => manager
    end

    redirect_to :action => :edit, :id => @node.id
  end

  protected

  def load_node
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:id]) || @network
  end

end
