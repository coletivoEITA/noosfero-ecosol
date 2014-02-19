module NetworksPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include TermsHelper

  def terms_context
    'networks_plugin'
  end

end
