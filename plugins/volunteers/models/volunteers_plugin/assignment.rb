class VolunteersPlugin::Assignment < ActiveRecord::Base

  belongs_to :profile
  belongs_to :period, class_name: 'VolunteersPlugin::Period'

  validates_presence_of :profile
  validates_presence_of :period

end
