require_dependency 'sub_organizations_plugin/relation'

class SubOrganizationsPlugin::Relation

  # np: non polymorphic versions
  belongs_to :parent_np, :foreign_key => :parent_id
  belongs_to :child_np, :foreign_key => :child_id

end
