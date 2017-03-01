class ElearningSecretaryPlugin::ContextSerializer < ApplicationSerializer

  has_many :sub_organizations, serializer: ElearningSecretaryPlugin::OrganizationSerializer

  has_many :students, serializer: ElearningSecretaryPlugin::StudentSerializer

  has_many :documents, serializer: ElearningSecretaryPlugin::DocumentSerializer

  def students
    Person.members_of(self.organizations).order('name ASC').eager_load(:memberships)
  end

  def sub_organizations
    @sub_organizations ||= Organization.children(self.object).order('name ASC').all
  end
  def organizations
    @organizations ||= [self.object] + self.sub_organizations
  end

  def documents
    parent = Organization.parents(self.object).first
    organizations = if parent then [parent] else [] end
    organizations.concat self.organizations
    organizations.flat_map{ |o| o.web_odf_documents.includes :profile }
  end

end
