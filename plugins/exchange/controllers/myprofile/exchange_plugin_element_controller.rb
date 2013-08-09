class ExchangePluginElementController < MyProfileController

  no_design_blocks
  protect 'edit_profile', :profile

  def create
    @element = ExchangePlugin::Element.new
    object_id = params[:element][:object_id]
    object_type = params[:element][:object_type] || @element.object_type

    if object_id.present?
      @element.object = object_type.constantize.find params[:element][:object_id]
    else
      if object_type == 'CurrencyPlugin::Currency'
        @element.object_id = environment.default_currency.id
      else
        @element.object_id = object_type.constantize.create.id
      end
    end
    @element.update_attributes! params[:element]
  end

  def edit
    @element = ExchangePlugin::Element.find params[:id]
    @element.update_attributes! params[:element]

    render :nothing => true
  end

  def destroy
    @element = ExchangePlugin::Element.find params[:id]
    @element.destroy
  end

end
