require_dependency 'person'
require_relative 'profile'

class Person

  soft_delete_associations_with_deleted :user

end
