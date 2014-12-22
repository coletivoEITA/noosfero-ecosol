require_dependency 'search_controller'
SearchController.helper SolrPlugin::SearchHelper
SearchController.include SolrPlugin::FacetsBrowse

