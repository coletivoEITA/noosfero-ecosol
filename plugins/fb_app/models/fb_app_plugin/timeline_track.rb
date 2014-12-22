class FbAppPlugin::TimelineTrack < ActiveRecord::Base

  belongs_to :profile
  belongs_to :object_owner, polymorphic: true

  validates_presence_of :profile
  validates_presence_of :object_owner

end
