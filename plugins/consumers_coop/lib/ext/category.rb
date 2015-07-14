require_dependency 'category'

class Category

  scope :name_like, -> (name) { where 'name ILIKE ?', "%#{name}%" }

end
