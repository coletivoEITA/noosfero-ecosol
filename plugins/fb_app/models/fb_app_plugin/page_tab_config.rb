class FbAppPlugin::PageTabConfig < ActiveRecord::Base

  belongs_to :profile

  acts_as_having_settings field: config

  validates_presence_of :page_id
  validates_uniqueness_of :page_id

  def blank?
    self.profiles.blank? and self.query.blank?
  end

  def profiles
    return nil if self.config[:type] != 'profiles'
    Profile.where(:id => self.config[:data])
  end

  def profiles= profiles
    self.config[:type] = 'profiles'
    self.config[:data] = profiles.map(&:id)
  end

  def profile_ids= profile_ids
    self.profiles = Profile.where id: profile_ids.to_a
  end

  def query
    return nil if self.config[:type] != 'query'
    self.config[:data]
  end

  def query= value
    self.config[:type] = 'query'
    self.config[:data] = value if self.config[:type] = 'query'
  end

end
