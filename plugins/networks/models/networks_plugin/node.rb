class NetworksPlugin::Node < Organization

  has_many :child_relations, :foreign_key => :child_id, :class_name => 'SubOrganizationsPlugin::Relation'
  has_many :parent_relations, :foreign_key => :parent_id, :class_name => 'SubOrganizationsPlugin::Relation'

end
