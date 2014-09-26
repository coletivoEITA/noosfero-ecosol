module CatalogHelper

  protected

  include DisplayHelper
  include ManageProductsHelper

  def catalog_load_index options = {:page => params[:page], :show_categories => true}
    @query = params[:query].to_s
    @scope = profile.products
    solr_options = {:all_facets => @query.blank?}
    paginate_options = {:per_page => profile.products_per_catalog_page, :page => options[:page]}
    paginate_options[:page] = '1' if paginate_options[:page].blank?
    @offset = (paginate_options[:page].to_i-1) * paginate_options[:per_page].to_i

    result = find_by_contents :catalog, @scope, @query, paginate_options, solr_options
    @products = result[:results]
    # FIXME: the categories and qualifiers filters are currently only work with solr plugin, because they depend on facets.
    @categories = result[:categories].to_a
    @qualifiers = result[:qualifiers].to_a
    @order = params[:order]
    @ordering = plugins_search_order :catalog

    @not_searched = @query.blank? && params[:category].blank? && params[:qualifier].blank?

  end

  def breadcrumb(category)
    start = link_to(_('Start'), {:controller => :catalog, :action => 'index'})
    ancestors = category.ancestors.map { |c| link_to(c.name, {:controller => :catalog, :action => 'index', :level => c.id}) }.reverse
    current_level = content_tag('strong', category.name)
    all_items = [start] + ancestors + [current_level]
    content_tag('div', all_items.join(' &rarr; '), :id => 'breadcrumb')
  end

  def category_link(category)
    count = profile.products.from_category(category).count
    name = truncate(category.name, :length => 22 - count.to_s.size)
    link = link_to(name, {:controller => 'catalog', :action => 'index', :level => category.id}, :title => category.name)
    content_tag('div', "#{link} <span class=\"count\">#{count}</span>") if count > 0
  end

  def category_with_sub_list(category)
    content_tag 'li', "#{category_link(category)}\n#{sub_category_list(category)}"
  end

  def sub_category_list(category)
    sub_categories = []
    category.children.order(:name).each do |sub_category|
      cat_link = category_link sub_category
      sub_categories << content_tag('li', cat_link) unless cat_link.nil?
    end
    content_tag('ul', sub_categories.join) if sub_categories.size > 0
  end

end
