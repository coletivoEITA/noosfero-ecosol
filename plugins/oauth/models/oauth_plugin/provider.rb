class OauthPlugin::Provider < ActiveRecord::Base

  attr_accessible :strategy, :identifier, :name, :site, :key, :secret, :environment_id

  belongs_to :environment

  validates_inclusion_of :strategy, in: OauthPlugin::StrategiesDefs.keys
  validates_presence_of :identifier
  validates_presence_of :name
  validates_uniqueness_of :identifier, scope: :environment_id
  validates_presence_of :key, :secret, if: :key_needed?

  acts_as_having_image
  after_update :save_image

  def strategy_class
    @strategy_class ||= OmniAuth::Strategies.const_get OmniAuth::Utils.camelize self.strategy
  end
  def strategy_defs
    @strategy_defs ||= OauthPlugin::StrategiesDefs[self.strategy] || {}
  end

  IconDefault = "/plugins/oauth/images/%s-icon.png"
  def default_icon
    IconDefault % self.strategy_defs[:identifier]
  end

  def image_public_filename size='icon'
    if self.image
      self.image.public_filename size
    elsif File.file? "#{Rails.root}/public/#{default_icon}"
      self.default_icon
    end
  end

  protected

  def key_needed?
    self.strategy_defs[:key_needed]
  end

  def save_image
    image.save if image
  end

end
