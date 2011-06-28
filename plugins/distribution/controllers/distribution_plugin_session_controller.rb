class DistributionOrderSessionController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def new
    @session = DistributionOrderSession.create!(:node => params[:node_id])
    redirect_to :action => :edit, :id => ss.id
  end

  def edit
    @session = DistributionOrderSession.find_by_id(params[:id])
  end

  def close
    @session = DistributionOrderSession.find_by_id(params[:id])
    @session.close
  end

end
