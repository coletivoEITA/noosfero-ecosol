class CatalogController < PublicController

  needs_profile
  # don't work with topleft
  #use_custom_design boxes_limit: 2

  #before_filter :check_enterprise_and_environment

  def index
    catalog_load_index
  end

  def search_autocomplete
    load_search_autocomplete
    respond_to do |format|
      format.json
    end
  end

  protected

  def check_enterprise_and_environment
    unless profile.enterprise? && @profile.environment.enabled?('products_for_enterprises')
      redirect_to controller: 'profile', profile: profile.identifier, action: 'index'
    end
  end

end
