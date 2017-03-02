class SuppliersPlugin::Consumer < SuppliersPlugin::Supplier

  self.table_name = :suppliers_plugin_suppliers

  before_validation :sync_profile

  attr_accessible :email, :phone, :cell_phone, :hub_id, :address, :city, :state, :zip

  belongs_to :profile, foreign_key: :consumer_id
  belongs_to :supplier, foreign_key: :profile_id
  alias_method :consumer, :profile

  belongs_to :hub

  def name= value
    self['name'] = value
  end
  def name
    self['name']
  end
  def description= value
    self['description'] = value
  end
  def description
    self['description']
  end

  def hub_name
    self.hub.nil? ? '' : self.hub.name
  end

  def sync_profile profile=nil
    profile = self.profile if profile.nil?
    return if profile.community?

    fields = {name: :name, contact_email: :email, contact_phone: :phone, cell_phone: :cell_phone, address: :address, city: :city, state: :state, zip_code: :zip}
    dirty = false

    fields.each do |profile_k, consumer_k|
      profile_v  = profile.send "#{profile_k}"
      consumer_v = self.send "#{consumer_k}"
      if profile_v.present? && consumer_v.blank?
        self.send "#{consumer_k}=", profile_v
        dirty = true
      end
    end

  end
end
