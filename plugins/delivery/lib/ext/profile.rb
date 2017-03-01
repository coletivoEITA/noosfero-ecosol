require_dependency 'profile'

class Profile

  has_many :delivery_methods, -> { order 'id ASC' }, class_name: 'DeliveryPlugin::Method', foreign_key: :profile_id, dependent: :destroy

end
