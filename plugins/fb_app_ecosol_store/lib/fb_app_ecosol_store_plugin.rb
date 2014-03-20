
class FbAppEcosolStorePlugin < Noosfero::Plugin

  def self.plugin_name
    'FB EcoSol Store'
  end

  def self.plugin_description
    'FB EcoSol Store'
  end

  def stylesheet?
    true
  end

  def js_files
    ['fb_app_ecosol_store_plugin.js','typeahead.bundle.js'].map{ |j| "javascripts/#{j}" }
  end

end
