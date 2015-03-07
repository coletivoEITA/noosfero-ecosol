module SolrPlugin

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    "Solr"
  end

  def self.plugin_description
    _("Uses Solr as search engine.")
  end

end

