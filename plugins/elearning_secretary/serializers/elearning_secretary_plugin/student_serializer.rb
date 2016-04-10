class ElearningSecretaryPlugin::StudentSerializer < ActiveModel::Serializer

  attributes :id, :identifier, :name, :org_ids

  #has_many :participations, serializer: ElearningSecretaryPlugin::ParticipationSerializer

  def org_ids
    self.object.membership_ids
  end


end
