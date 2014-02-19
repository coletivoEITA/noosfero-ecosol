class CatalogController < PublicController

  needs_profile
  use_custom_design :boxes_limit => 2, :insert => {:box => 2, :position => 0, :block => ProductCategoriesBlock}

  before_filter :check_enterprise_and_environment

  def index
    extend CatalogHelper
    catalog_load_index
  end

  protected

  def check_enterprise_and_environment
    unless profile.enterprise? && @profile.environment.enabled?('products_for_enterprises')
      redirect_to :controller => 'profile', :profile => profile.identifier, :action => 'index'
    end
  end

end
