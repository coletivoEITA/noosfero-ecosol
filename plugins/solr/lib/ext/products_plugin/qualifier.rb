if defined? ProductsPlugin

require_dependency 'products_plugin/qualifier'

ActiveSupport.run_load_hooks :solr_qualifier

module ProductsPlugin
  class Qualifier

    after_save_reindex [:products], with: :delayed_job

    acts_as_searchable fields: SEARCHABLE_FIELDS.map{ |field, options|
      {field => {boost: options[:weight]}}
    }

  end
end

end
