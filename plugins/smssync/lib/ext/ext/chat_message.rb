require_dependency 'chat_message'

class ChatMessage

  has_one :smssync_message, class_name: 'SmssyncPlugin::Message'

end
