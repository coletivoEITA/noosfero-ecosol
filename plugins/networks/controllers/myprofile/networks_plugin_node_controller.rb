class NetworksPluginNodeController < MyProfileController

  def create
    @node = NetworksPlugin::Node.new((params[:node] || {}).merge(:environment => environment))

    if params[:commit]
      @node.identifier = @node.name.to_slug
      @node.parent_relations.build :parent => profile, :child => @node
      if @node.save
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

  def show
    @node = NetworksPlugin::Node.find params[:id]
  end

  def edit
    @node = NetworksPlugin::Node.find params[:id]

    if request.post?
      @node.update_attributes params[:networks_plugin_node]
    end
  end

  def destroy
    relation = SubOrganizationsPlugin::Relation.find_by_id params[:id]

    if relation
      @net = relation.parent
      if relation.destroy
        flash[:notice] = "Entidade removida da rede com sucesso."
      else
        flash[:error] = "Entidade não pode ser removida da rede."
      end
    else
      #TODO: raise an exception
      flash[:error] = "Entidade não existe nesta rede."
    end

    redirect_to :controller => :networks_plugin_network, :action => :show_structure
  end

  protected

end
