class VolunteersPlugin::Period < ActiveRecord::Base

  extend SplitDatetime::SplitMethods
  split_datetime :start
  split_datetime :end

  attr_accessible :name
  attr_accessible :start_date, :start_time, :end_date, :end_time
  attr_accessible :owner_type

  belongs_to :owner, polymorphic: true

  has_many :assignments, class_name: 'VolunteersPlugin::Assignment', foreign_key: :period_id, include: [:profile]

  validates_presence_of :owner
  validates_presence_of :name
  validates_presence_of :start_date, :start_time, :end_date, :end_time

end
