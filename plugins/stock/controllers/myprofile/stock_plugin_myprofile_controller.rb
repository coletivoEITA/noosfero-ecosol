class StockPluginMyprofileController < MyProfileController

  include StockPlugin::TranslationHelper

  no_design_blocks

  protect 'edit_profile', :profile

  helper StockPlugin::DisplayHelper

  def index
  end

  def edit
    @place = profile.stock_places.find params[:id]
    @place.update! params[:place]
    redirect_to :action => :index
  end

  def create
    @place = profile.stock_places.build
    @place.update! params[:place]
    redirect_to :action => :index
  end

  protected

end
