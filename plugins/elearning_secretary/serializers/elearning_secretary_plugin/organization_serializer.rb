class ElearningSecretaryPlugin::OrganizationSerializer < ActiveModel::Serializer

  attributes :id, :name

  #has_many :students, serializer: ElearningSecretaryPlugin::StudentSerializer

  def students
    self.object.members.order('name ASC')
  end


end
