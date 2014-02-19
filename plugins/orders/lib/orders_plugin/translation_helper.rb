module OrdersPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include TermsHelper

  def terms_context
    'orders_plugin'
  end

end
