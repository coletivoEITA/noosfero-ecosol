module NetworksPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include TermsHelper

  def i18n_scope
    ['networks_plugin', 'suppliers_plugin', 'orders_plugin']
  end

end
