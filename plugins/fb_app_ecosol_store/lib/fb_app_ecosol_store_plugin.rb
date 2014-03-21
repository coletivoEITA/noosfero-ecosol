
class FbAppEcosolStorePlugin < Noosfero::Plugin

  def self.plugin_name
    'Loja de Economia Solidária no Facebook'
  end

  def self.plugin_description
    'Monte uma loja virtual da economia solidária em suas páginas do facebook!'
  end

  def stylesheet?
    true
  end

  def js_files
    ['fb_app_ecosol_store_plugin.js','typeahead.bundle.js'].map{ |j| "javascripts/#{j}" }
  end

end
