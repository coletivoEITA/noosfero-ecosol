require_dependency 'scrap'

ActiveSupport.run_load_hooks :solr_scrap

class Scrap

  acts_as_searchable fields: SEARCHABLE_FIELDS.map{ |field, options|
    {field => {boost: options[:weight]}}
  }

end
