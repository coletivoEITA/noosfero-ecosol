require_dependency 'organization'

class Organization

  def add_member_with_consumer person
    add_member_without_consumer person

    return unless self.consumers_coop_settings.enabled?
    self.add_consumer person
  end
  def remove_member_with_consumer person
    remove_member_without_consumer person

    return unless self.consumers_coop_settings.enabled?
    self.remove_consumer person
  end
  alias_method_chain :add_member, :consumer
  alias_method_chain :remove_member, :consumer

end
