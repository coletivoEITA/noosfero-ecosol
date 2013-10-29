module SuppliersPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include SuppliersPlugin::TermsHelper

  def terms_context
    'suppliers_plugin'
  end

end
