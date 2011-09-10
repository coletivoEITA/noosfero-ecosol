class DistributionPluginNodeController < DistributionPluginMyprofileController

  no_design_blocks

  def edit
    @node = DistributionPluginNode.find params[:id]
    @node.update_attributes params[:node]
    render :nothing => true
  end

end
