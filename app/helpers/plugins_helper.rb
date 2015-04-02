module PluginsHelper

  include Noosfero::Plugin::HotSpot

  def plugins_product_tabs
    @plugins.dispatch(:product_tabs, @product).map do |tab|
      {:title => tab[:title], :id => tab[:id], :content => instance_exec(&tab[:content])}
    end
  end

  def plugins_article_toolbar_actions
    @plugins.dispatch(:article_toolbar_actions, @page).collect { |content| instance_exec(&content) }.join ""
  end

  def plugins_catalog_search_extras_begin
    @plugins.dispatch(:catalog_search_extras_begin).map do |content|
      instance_exec(&content)
    end.join
  end

  def plugins_catalog_search_extras_end
    @plugins.dispatch(:catalog_search_extras_end).map do |content|
      instance_exec(&content)
    end.join
  end

  def plugins_catalog_autocomplete_item_extras product
    @plugins.dispatch(:catalog_autocomplete_item_extras, product).map do |content|
      instance_exec(&content)
    end.join
  end

  def plugins_search_order asset
    @plugins.dispatch_first :search_order, asset
  end

  def plugins_search_pre_contents
    @plugins.dispatch(:search_pre_contents).map do |content|
      instance_exec(&content)
    end.join
  end
  
  def plugins_search_post_contents
    @plugins.dispatch(:search_post_contents).map do |content|
      instance_exec(&content)
    end.join
  end

end

