if defined? ProductsPlugin

require_dependency 'products_plugin/product_category'

module ProductsPlugin
  class ProductCategory

    after_save_reindex [:products], with: :delayed_job

  end
end

end
