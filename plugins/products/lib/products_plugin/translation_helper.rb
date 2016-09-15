module ProductsPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include TermsHelper

  def i18n_scope
    ['products_plugin']
  end

end
