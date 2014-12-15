class FbAppPlugin::PageTab < ActiveRecord::Base

  # FIXME: rename table to match model
  self.table_name = :fb_app_plugin_page_tab_configs

  attr_accessible :profile, :profile_id, :page_id, :config_type, :profile_ids, :query

  belongs_to :owner_profile, foreign_key: :profile_id, class_name: 'Profile'

  acts_as_having_settings field: :config

  ConfigTypes = [:profile, :profiles, :query]

  validates_presence_of :page_id
  validates_uniqueness_of :page_id
  validates_inclusion_of :config_type, in: ConfigTypes

  def self.page_ids_from_tabs_added tabs_added
    tabs_added.map{ |id, value| id }
  end

  def self.create_from_page_ids page_ids, attrs = {}
    page_ids.map do |page_id|
      page_tab = FbAppPlugin::PageTab.where(page_id: page_id).first
      page_tab = FbAppPlugin::PageTab.build page_id: page_id
      page_tab.attributes = attrs
      page_tab.save!
      page_tab
    end
  end
  def self.create_from_tabs_added tabs_added, attrs = {}
    page_ids = self.page_ids_from_tabs_added tabs_added
    self.create_from_page_ids page_ids, attrs
  end

  def config_type
    self.config[:type] || :profile
  end
  def config_type= value
    # ignored, set by specific methods belows
  end

  def value
    self.send self.config_type rescue nil
  end
  def blank?
    self.value.blank? rescue true
  end

  def profiles
    Profile.where(id: self.config[:profile_ids])
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

  def profile_ids= ids
    ids = ids.split(',')
    self.config[:type] = if ids.size == 1 then :profile else :profiles end
    self.config[:profile_ids] = ids
  end

  def profiles= profiles
    self.config[:type] = :profiles
    self.config[:profile_ids] = profiles.map(&:id)
  end

  def profile= profile
    self.config[:type] = :profile
    self.config[:profile_ids] = [profile.id]
  end

  def query= value
    self.config[:type] = :query
    self.config[:query] = value
  end

end
