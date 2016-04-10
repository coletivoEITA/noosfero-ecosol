class StockPluginProductsController < MyProfileController

  include StockPlugin::TranslationHelper

  no_design_blocks

  protect 'manage_products', :profile

  helper StockPlugin::DisplayHelper

  def update
    @product = profile.products.find params[:id]
    @place = profile.stock_places.find params[:allocation][:place_id]
    @allocation = @product.stock_allocations.where(:place_id => @place.id).first
    @allocation ||= @product.stock_allocations.build :place => @place
    @allocation.update! params[:allocation]
    render :nothing => true
  end

  protected

end
