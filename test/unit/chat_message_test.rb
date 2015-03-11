require 'test_helper'

class ChatMessageTest < ActiveSupport::TestCase
  should 'create message' do
    assert_difference 'ChatMessage.count', 1 do
      ChatMessage.create!(:from => 'jack@example.org', :to => 'mary@exampale.org', :message => 'Hey! How are you?' )
    end
  end
end
