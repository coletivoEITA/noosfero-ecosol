module SuppliersPlugin::TranslationHelper

  protected

  def set_terms_context
    @terms_context = 'suppliers_plugin'
  end

  def self.included base
    base.before_filter :set_terms_context
  end

end
