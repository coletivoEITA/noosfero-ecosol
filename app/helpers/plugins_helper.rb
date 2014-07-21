module PluginsHelper

  def plugins_product_tabs
    @plugins.dispatch(:product_tabs, @product).map do |tab|
      {:title => tab[:title], :id => tab[:id], :content => instance_eval(&tab[:content])}
    end
  end

  def plugins_article_toolbar_actions
    @plugins.dispatch(:article_toolbar_actions, @page).collect { |content| instance_eval(&content) }.join ""
  end

end
