require_dependency 'license'

ActiveSupport.run_load_hooks :solr_license

class License

  acts_as_searchable fields: SEARCHABLE_FIELDS.map{ |field, options|
    {field => {boost: options[:weight]}}
  }

end
