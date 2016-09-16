class SuppliersPlugin::Consumer < SuppliersPlugin::Supplier

  self.table_name = :suppliers_plugin_suppliers

  after_save :sync_profile

  attr_accessible :name, :email, :phone, :cell_phone, :hub_id, :address, :city, :state, :zip

  belongs_to :profile, foreign_key: :consumer_id
  belongs_to :supplier, foreign_key: :profile_id
  alias_method :consumer, :profile

  belongs_to :hub

  def sync_profile profile=nil
    profile = self.profile if profile.nil?
    return if profile.community?

    fields = {name: :name, contact_email: :email, contact_phone: :phone, cell_phone: :cell_phone, address: :address, city: :city, state: :state, zip_code: :zip}
    dirty = false

    fields.each do |profile_k, consumer_k|
      profile_v  = profile.send "#{profile_k}"
      pp profile_v
      consumer_v = self.send "#{consumer_k}"
      if profile_v.present? && profile_v != consumer_v
        self.send "#{consumer_k}=", profile_v
        dirty = true
      end
    end

    self.save if dirty
  end
end
