class NetworksPlugin::BaseNode < Organization

  self.abstract_class = true

  has_many :as_child_relations, :foreign_key => :child_id, :class_name => 'SubOrganizationsPlugin::Relation', :dependent => :destroy, :include => [:parent]
  has_many :as_parent_relations, :foreign_key => :parent_id, :class_name => 'SubOrganizationsPlugin::Relation', :include => [:child]
  def as_child_relation
    self.as_child_relations.first
  end

  delegate :parent, :to => :as_child_relation, :allow_nil => true
  def parent= node
    self.as_child_relations = []
    self.as_child_relations.build :parent => node, :child => self
  end

  # FIXME: use acts_as_filesystem
  def hierarchy
    @hierarchy = []
    item = self
    while item
      @hierarchy.unshift(item)
      item = item.parent
    end
    @hierarchy
  end

  def nodes
    self.as_parent_relations.all(:conditions => {:child_type => 'NetworksPlugin::Node'}).collect &:child
  end

  def node?
    false
  end
  def network?
    false
  end

  protected

  def default_template
    return if self.is_template
    self.environment.network_template
  end

end
