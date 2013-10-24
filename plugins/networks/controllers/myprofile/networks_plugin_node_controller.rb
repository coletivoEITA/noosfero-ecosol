class NetworksPluginNodeController < MyProfileController

  include NetworksPlugin::TranslationHelper

  before_filter :load_node, :only => [:associate]

  def associate
    @new_node = NetworksPlugin::Node.new((params[:node] || {}).merge(:environment => environment))
    @new_node.parent = @node

    if params[:commit]
      if @new_node.save
        render :partial => 'suppliers_plugin_shared/pagereload'
      else
        respond_to do |format|
          format.js
        end
      end
    else
      respond_to do |format|
        format.html{ render :layout => false }
      end
    end
  end

  def edit
    @node = NetworksPlugin::Node.find params[:id]

    if request.post?
      @node.update_attributes params[:profile_data]
    end
  end

  def destroy
    @node = NetworksPlugin::Node.find params[:id]
    @node.destroy
  end

  protected

  def load_node
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:id]) || @network
  end

end
