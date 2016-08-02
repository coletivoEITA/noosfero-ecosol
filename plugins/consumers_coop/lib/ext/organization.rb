require_dependency 'organization'

class Organization

  module ConsumerMember

    def affiliate person, *args
      self.add_consumer person if self.consumers_coop_settings.enabled

      super person, *args
    end

    def remove_member person
      self.remove_consumer person if self.consumers_coop_settings.enabled

      super person
    end
  end

  prepend ConsumerMember

end
