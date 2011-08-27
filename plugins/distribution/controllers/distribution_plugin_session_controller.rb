class DistributionPluginSessionController < DistributionPluginMyprofileController
  no_design_blocks

  helper DistributionPlugin::SessionHelper

  before_filter :set_admin_action, :only => [:index, :new, :edit]

  def index
    @sessions = @node.sessions
  end

  def new
    @session = DistributionPluginSession.new(:node => @node)
    @session.status = 'new'
    if request.post?
      @session.update_attributes(params[:session])
      @session.save!
      redirect_to :action => :edit, :id => @session.id
    end
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
