require_dependency 'license'

class License

  acts_as_searchable fields: SEARCHABLE_FIELDS.map{ |field, options|
    {field => {boost: options[:weight]}}
  }

end
