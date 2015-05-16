require_dependency 'user'

class User

  acts_as_searchable fields: SEARCHABLE_FIELDS.map{ |field, options|
    {field => {boost: options[:weight]}}
  }

end
