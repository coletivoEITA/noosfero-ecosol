class OauthPlugin::Provider < Noosfero::Plugin::ActiveRecord

  belongs_to :environment

  validates_inclusion_of :strategy, :in => OauthPlugin::StrategiesDefs.keys
  validates_presence_of :identifier
  validates_presence_of :name
  validates_uniqueness_of :identifier, :scope => :environment_id
  validates_presence_of :key, :secret, :if => :key_needed?

  acts_as_having_image
  after_update :save_image

  def strategy_defs
    OauthPlugin::StrategiesDefs[self.strategy] || {}
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
    self.strategy != 'persona'
  end

  def save_image
    image.save if image
  end

end
