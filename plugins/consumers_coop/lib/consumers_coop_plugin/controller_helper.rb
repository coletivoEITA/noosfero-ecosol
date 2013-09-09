module ConsumersCoopPlugin::ControllerHelper

  protected

  def set_admin_action
    @admin_action = true
    @admin_edit = user && user != @consumer
  end

  def content_classes
    "consumers-coop consumers-coop-layout"
  end

  def custom_layout?
    true
  end

end
