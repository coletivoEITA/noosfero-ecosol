class DistributionPluginOrderPublicController < DistributionPluginProfileController

  no_design_blocks

  def index
    @year = (params[:year] || DateTime.now.year).to_s
    @sessions = @node.sessions.by_year @year
    @consumer = @user_node
  end

end
