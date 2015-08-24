require_dependency 'qualifier'

ActiveSupport.run_load_hooks :solr_qualifier

class Qualifier

  after_save_reindex [:products], with: :delayed_job

  acts_as_searchable fields: SEARCHABLE_FIELDS.map{ |field, options|
    {field => {boost: options[:weight]}}
  }

end

