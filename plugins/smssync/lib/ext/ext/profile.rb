require_dependency 'profile'

class Profile

  has_many :smssync_sent_messages, foreign_key: :from_profile_id, class_name: 'SmssyncPlugin::Message'
  has_many :smssync_received_messages, foreign_key: :to_profile_id, class_name: 'SmssyncPlugin::Message'

end
