require_dependency 'search_controller'
require_dependency 'solr_plugin/facets_browse'
require_dependency 'solr_plugin/search_helper'

SearchController.class_eval do

  include SolrPlugin::FacetsBrowse

  helper SolrPlugin::SearchHelper

  before_filter :solr_enterprise, only: [:enterprises]

  protected

  def solr_enterprise
    redirect_to url_for(params.merge facet: {solr_f_enabled: true}) if params[:facet].blank? and params[:query].blank?
  end

end
