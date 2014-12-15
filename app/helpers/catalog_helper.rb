module CatalogHelper

  protected

  include DisplayHelper
  include ManageProductsHelper

  def catalog_load_index options = {:page => params[:page], :show_categories => true}
    @catalog_bar = true
    @use_show_more = params[:use_show_more] == '1'

    @base_query = options[:base_query].to_s
    @query = params[:query].to_s
    @final_query = "#{@base_query} #{@query}"
    @scope = options[:scope] || profile.products
    solr_options = {:all_facets => @query.blank?}

    base_per_page = profile.products_per_catalog_page rescue 24

    @rank = params[:rank].to_i
    @pg_page = if options[:page].present? then options[:page].to_i else 1 end
    if (@rank > base_per_page)
      page_offset = (@rank/base_per_page)+1
      if (@pg_page==1)
        @per_page = page_offset*base_per_page
      else
        @per_page = base_per_page
        if (@pg_page==2)
          @pg_page += (page_offset-1)
        end
      end
    else
      @per_page = base_per_page
    end
    paginate_options = {per_page: @per_page, page: @pg_page}
    @offset = (@pg_page-1) * @per_page

    # FIXME
    if self.respond_to? :controller
      result = controller.send :find_by_contents, :catalog, @scope, @final_query, paginate_options, solr_options
    else
      result = find_by_contents :catalog, @scope, @final_query, paginate_options, solr_options
    end

    @products = result[:results]
    # FIXME: the categories and qualifiers filters currently only work with solr plugin, because they depend on facets.
    @categories = result[:categories].to_a
    @qualifiers = result[:qualifiers].to_a
    @order = params[:order]
    @ordering = plugins_search_order(:catalog) || {select_options: []}

    @not_searched = @query.blank? && params[:category].blank? && params[:qualifier].blank?

  end

  def link_to_product_from_catalog product, options = {}
    link_to_product product, options
  end

end
