require_dependency 'category'

class Category

  scope :name_like, lambda { |name|
    { :conditions => ['LOWER(name) LIKE ?', "%#{name}%"] }
  }

end
