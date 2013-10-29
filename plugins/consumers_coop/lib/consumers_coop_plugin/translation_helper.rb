module ConsumersCoopPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include SuppliersPlugin::TermsHelper

  def terms_context
    'consumers_coop_plugin'
  end

end
