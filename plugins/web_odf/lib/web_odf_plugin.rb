module WebODFPlugin

  EmptyDocument = File.expand_path "#{__FILE__}/../../public/empty.odt"

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    I18n.t'webodf_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t'webodf_plugin.lib.plugin.description'
  end

end
WebOdfPlugin = WebODFPlugin

