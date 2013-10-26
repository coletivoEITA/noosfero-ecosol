module ConsumersCoopPlugin::TranslationHelper

  protected

  def set_terms_context
    @terms_context = 'consumers_coop_plugin'
  end

  def self.included base
    base.before_filter :set_terms_context
  end

  include SuppliersPlugin::TermsHelper

end
