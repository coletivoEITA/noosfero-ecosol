class TeamsPlugin::Work < ActiveRecord::Base

  belongs_to :team
  belongs_to :work, polymorphic: true, dependent: :destroy

end
