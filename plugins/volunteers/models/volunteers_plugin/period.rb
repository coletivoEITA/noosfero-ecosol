class VolunteersPlugin::Period < ActiveRecord::Base

  belongs_to :owner, polymorphic: true

  validates_presence_of :owner

end
