require 'test_helper'

class ProfileTest < ActiveSupport::TestCase

  should 'be able to load a deleted profile and its user' do
    user = create_user
    person = user.person
    person_id = person.id

    person.destroy
    deleted_person = Person.with_deleted.find person_id
    assert_equal person, deleted_person

    # association
    assert_equal user, deleted_person.user

  end

end
