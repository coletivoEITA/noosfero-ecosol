class CatalogController < PublicController

  needs_profile
  use_custom_design :boxes_limit => 2

  include CatalogHelper

  include CatalogHelper

  before_filter :check_enterprise_and_environment

  def index
    catalog_load_index
    render partial: 'catalog/results' if request.xhr?
  end

  def search_autocomplete
    @query = params[:query].to_s
    @scope = profile.products
    @products = autocomplete(:catalog, @scope, @query, {:per_page => 5}, {})[:results]
    respond_to do |format|
      format.json
    end
  end

  protected

  def check_enterprise_and_environment
    unless profile.enterprise? && @profile.environment.enabled?('products_for_enterprises')
      redirect_to :controller => 'profile', :profile => profile.identifier, :action => 'index'
    end
  end

end
