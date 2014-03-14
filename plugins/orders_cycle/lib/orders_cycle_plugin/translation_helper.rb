module OrdersCyclePlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include SuppliersPlugin::TermsHelper

  def i18n_scope
    ['orders_cycle_plugin', 'orders_plugin', 'suppliers_plugin']
  end

end
