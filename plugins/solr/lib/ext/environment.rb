require_dependency 'environment'

class Environment

  settings_items :solr_plugin_top_level_category_as_facet_ids, type: Array, default: []
  
  #types: :city (default), :state, :region
  settings_items :solr_plugin_region_facet_type, type: Symbol, :default => :city

end
