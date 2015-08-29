require_dependency 'national_region'

ActiveSupport.run_load_hooks :solr_national_region

class NationalRegion

  acts_as_searchable fields: SEARCHABLE_FIELDS.map{ |field, options|
    {field => {boost: options[:weight]}}
  }

end
