module ProductsPlugin
  class SearchController < ::SearchController

    helper ProductsHelper
    helper CatalogHelper

    def products
      @scope = @environment.products.enabled.is_public.includes(
        :product_category, :unit, :image, {inputs: [:product_category]},
        {product_qualifiers: [:qualifier, :certifier]},
        {price_details: [:production_cost]},
        {profile: [:region, :domains]},
      )
      full_text_search
    end

    protected

    # inherit routes from core skipping use_relative_controller!
    def url_for options
      options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
      super options
    end
    helper_method :url_for

  end
end
