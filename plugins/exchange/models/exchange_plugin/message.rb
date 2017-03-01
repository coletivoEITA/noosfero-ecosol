class ExchangePlugin::Message < ActiveRecord::Base

  attr_accessible *self.column_names
  attr_accessible :proposal, :sender, :recipient, :person_sender

  belongs_to :proposal, class_name: "ExchangePlugin::Proposal"
  belongs_to :sender, class_name: "Profile"
  belongs_to :recipient, class_name: "Profile"
  belongs_to :person_sender, class_name: "Person"

  validates_presence_of :sender
  validates_presence_of :recipient
  validates_presence_of :person_sender
  validates_presence_of :body

  def self.new_exchange_message proposal, sender, recipient, person_sender, body
    m = self.new
    m.proposal = proposal
    m.sender = sender
    m.recipient = recipient
    m.person_sender = person_sender
    m.body = body
    m.save!
    m
  end

end
