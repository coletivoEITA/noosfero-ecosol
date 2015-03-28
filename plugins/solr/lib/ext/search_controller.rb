require_dependency 'search_controller'
require_dependency 'solr_plugin/facets_browse'
require_dependency 'solr_plugin/search_helper'

SearchController.helper SolrPlugin::SearchHelper
SearchController.include SolrPlugin::FacetsBrowse

