require_dependency 'category'

class Category

  named_scope :name_like, lambda { |name|
    { :conditions => ['LOWER(name) LIKE ?', "%#{name}%"] }
  }

end
