class DistributionPluginSessionController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  no_design_blocks
  layout false

  def index
    @node = DistributionPluginNode.find(params[:node_id])
    @sessions = @node.sessions
  end

  def new
    @session = DistributionPluginSession.create!(:node_id => params[:node_id])
    render :action => :edit, :id => @session.id
  end

  def edit
    @session = DistributionPluginSession.find_by_id(params[:id])
    if request.post?
      @session.update_attributes(params[:session])
      @session.save!
    end
  end

  def close
    @session = DistributionPluginSession.find_by_id(params[:id])
    @session.close
  end

end
