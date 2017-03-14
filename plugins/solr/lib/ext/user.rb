require_dependency 'user'

ActiveSupport.run_load_hooks :solr_user

class User

  extend SolrPlugin::ActsAsSearchable

  acts_as_searchable fields: SEARCHABLE_FIELDS.map{ |field, options|
    {field => {boost: options[:weight]}}
  }

end
