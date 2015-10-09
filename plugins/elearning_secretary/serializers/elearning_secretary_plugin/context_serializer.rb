class ElearningSecretaryPlugin::ContextSerializer < ActiveModel::Serializer

  has_many :sub_organizations, serializer: ElearningSecretaryPlugin::OrganizationSerializer

  has_many :students, serializer: ElearningSecretaryPlugin::StudentSerializer

  def students
    Person.members_of(self.sub_organizations + [self.object]).order('name ASC').eager_load(:memberships)
  end

  def sub_organizations
    @sub_organizations ||= Organization.children(self.object).order('name ASC').all
  end

end
