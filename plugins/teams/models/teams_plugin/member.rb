class TeamsPlugin::Member < ActiveRecord::Base

  belongs_to :team, class_name: 'TeamsPlugin::Team'
  belongs_to :profile

  validates_presence_of :team, :profile
  validates_uniqueness_of :profile_id, scope: :team_id

end
