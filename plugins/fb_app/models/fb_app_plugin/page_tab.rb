class FbAppPlugin::PageTab < ActiveRecord::Base

  # FIXME: rename table to match model
  self.table_name = :fb_app_plugin_page_tab_configs

  attr_accessible :profile, :profile_id, :page_id

  belongs_to :profile

  acts_as_having_settings field: :config

  ConfigTypes = [:profile, :profiles, :query]

  validates_presence_of :page_id
  validates_uniqueness_of :page_id
  validates_inclusion_of :config_type, in: ConfigTypes

  def config_type
    self.config[:type] || :profile
  end

  def value
    self.send self.config_type rescue nil
  end
  def blank?
    self.value.blank? rescue true
  end

  def profiles
    Profile.where(id: self.config[:data])
  end
  def profile
    self.profiles.first
  end
  def profile_ids
    self.profiles.map(&:id)
  end

  def query
    self.config[:query]
  end

  def profiles= profiles
    self.config[:type] = :profiles
    self.config[:profile_ids] = profiles.map(&:id)
  end

  def profile= profile
    self.config[:type] = :profile
    self.config[:profile_ids] = [profile]
  end

  def query= value
    self.config[:type] = :query
    self.config[:query] = value
  end

end
