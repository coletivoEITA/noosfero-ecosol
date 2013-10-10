module NetworksPlugin::TranslationHelper

  protected

  def set_terms_context
    @terms_context = 'networks_plugin'
  end

  def self.included base
    base.before_filter :set_terms_context
  end

end
