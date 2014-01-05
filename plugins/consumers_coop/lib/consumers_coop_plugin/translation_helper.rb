module ConsumersCoopPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include TermsHelper

  def terms_context
    'consumers_coop_plugin'
  end

end
