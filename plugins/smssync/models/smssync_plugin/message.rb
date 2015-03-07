class SmssyncPlugin::Message < ActiveRecord::Base

  attr_accessible *self.column_names

  belongs_to :to_profile, class_name: 'Profile'
  belongs_to :from_profile, class_name: 'Profile'
  belongs_to :chat_message

  before_validation :associate_profiles
  after_create :create_chat_message

  def self.associated_profiles phone
    # TODO: improve search
    Profile.where('contact_phone LIKE ?', "%#{phone.last 8}")
  end

  def sent_timestamp= value
    self['sent_timestamp'] = Time.at(value.to_i/1000).to_datetime rescue nil
  end

  protected

  def associate_profiles
    self.to_profile = self.class.associated_profiles(self.sent_to).first rescue nil
    self.from_profile = self.class.associated_profiles(self.from).first rescue nil
  end

  def create_chat_message
    return unless self.to_profile.present? and self.from_profile.present?
    self.chat_message = ChatMessage.create! to: self.to_profile, from: self.from_profile, body: self.message rescue nil
    self.save! if self.chat_message_id_changed?
  end

end
