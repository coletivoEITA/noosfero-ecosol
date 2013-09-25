module SuppliersPlugin::DisplayHelper

  protected

  include SuppliersPlugin::TableHelper
  include SuppliersPlugin::FieldHelper
  include SuppliersPlugin::ProductHelper

  def j *args
    escape_javascript *args
  end

end
