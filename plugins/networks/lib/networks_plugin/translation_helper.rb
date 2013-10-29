module NetworksPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include SuppliersPlugin::TermsHelper

  def terms_context
    'networks_plugin'
  end

end
