require_dependency 'profile'
require_dependency 'person'

class Person

  after_save :sync_consumers

  def sync_consumers
    self.consumers.each do |consumer|
      consumer.sync_profile
    end
  end
end
