require_dependency 'profile'

Profile.subclasses.each do |subclass|
  subclass.class_eval do
    attr_accessible :volunteers_settings
  end
end

class Profile

  def volunteers_settings
    @volunteers_settings ||= Noosfero::Plugin::Settings.new self, VolunteersPlugin
  end
  def volunteers_settings= hash
    hash.each do |attr, value|
      self.volunteers_settings.send "#{attr}=", value
    end
  end

end
