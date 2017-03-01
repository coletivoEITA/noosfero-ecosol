class TeamsPlugin::TeamFolder < Folder

  attr_accessible :team

  has_many :team_works, as: :work, class_name: 'TeamsPlugin::Work'
  has_one :team_work, as: :work, class_name: 'TeamsPlugin::Work'
  has_one :team, through: :team_work, class_name: 'TeamsPlugin::Team', autosave: true

  validates_presence_of :team

  def name
    self.team.profiles.map(&:name).join(', ')
  end

end
