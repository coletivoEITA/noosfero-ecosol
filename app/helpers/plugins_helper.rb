module PluginsHelper

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

end
