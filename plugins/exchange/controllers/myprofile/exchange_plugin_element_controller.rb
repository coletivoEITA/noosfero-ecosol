class ExchangePluginElementController < MyProfileController

  no_design_blocks
  protect 'edit_profile', :profile

  def edit
    @element = ExchangePlugin::Element.find params[:id]
    @element.update_attributes! params[:element]

    render :nothing => true
  end

end
