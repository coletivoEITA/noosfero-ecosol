class SuppliersPlugin::Hub < ApplicationRecord

  attr_accessible :name, :description, :profile_id

  belongs_to :profile
  has_many :consumers, class_name: 'SuppliersPlugin::Consumer'
  has_many :consumer_profiles, through: :consumers, source: :profile

end
