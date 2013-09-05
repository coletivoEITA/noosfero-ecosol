class NetworksPlugin::Node < Organization

  # This method recovers who is the parent of the node that called this method.
  # Returns the object that represents the parent of the caller.
  def is_child_of
    SubOrganizationsPlugin::Relation.find_by_child_id(self).parent
  end

end
