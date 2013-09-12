class NetworksPlugin::BaseNode < Organization

  self.abstract_class = true

  has_many :as_child_relations, :foreign_key => :child_id, :class_name => 'SubOrganizationsPlugin::Relation', :dependent => :destroy, :include => [:parent]
  has_many :as_parent_relations, :foreign_key => :parent_id, :class_name => 'SubOrganizationsPlugin::Relation', :dependent => :destroy, :include => [:child]

  def parent
    self.as_child_relations.first.parent
  end

  protected

  def default_template
    self.environment.enterprise_template
  end

end
