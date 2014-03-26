
class FbAppEcosolStorePlugin < Noosfero::Plugin

  def self.plugin_name
    'Loja de Economia Solidária no Facebook'
  end

  def self.plugin_description
    'Monte uma loja virtual da economia solidária em suas páginas do facebook!'
  end

  def self.config
    YAML.load File.read("#{File.dirname __FILE__}/../config.yml") rescue {}
  end

  def stylesheet?
    true
  end

  def js_files
    ['fb_app_ecosol_store_plugin.js', 'typeahead.bundle.js'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    #{ :title => self.class.plugin_name, :icon => 'fb-app-ecosol-store', :url => '/plugin/fb_app_ecosol_store' }
  end


end
