class WorkAssignmentPlugin::SubmissionSerializer < ApplicationSerializer

  attributes :id, :name, :path, :may_delete, :can_download, :created_at,
    :read_by_names, :user_read

  def may_delete
    self.object.allow_post_content? User.current.person if User.current
  end

  def can_download
    WorkAssignmentPlugin.can_download_submission? User.current.person, self.object if User.current
  end

  def created_at
    self.object.created_at.to_i
  end

  def user_read
    self.object.work_assignment_read_by_ids.include? User.current.person.id if User.current
  end

  def read_by_names
    self.object.work_assignment_read_by_names
  end

end
