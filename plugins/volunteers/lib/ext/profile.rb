require_dependency 'profile'

if Rails.env.development?
  require_dependency 'community'
  require_dependency 'enterprise'

  Organization.subclasses.each do |subclass|
    subclass.class_eval do
      attr_accessible :volunteers_settings
    end
  end
end

class Profile

  attr_accessible :volunteers_settings

  def volunteers_settings
    @volunteers_settings ||= Noosfero::Plugin::Settings.new self, VolunteersPlugin
  end
  def volunteers_settings= hash
    hash.each do |attr, value|
      self.volunteers_settings.send "#{attr}=", value
    end
  end

end
