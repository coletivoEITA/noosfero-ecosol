require_dependency 'profile'

([Profile] + Profile.descendants).each do |subclass|
subclass.class_eval do

  has_many :teams, class_name: 'TeamsPlugin::Team', as: :context

end
end
