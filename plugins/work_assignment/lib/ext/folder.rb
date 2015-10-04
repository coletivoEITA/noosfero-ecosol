require_dependency 'article'
require_dependency 'folder'

class Folder < Article

  after_save :work_assignment_sync_submissions_privacy

  def work_assignment_sync_submissions_privacy
    return unless self.parent.kind_of? WorkAssignmentPlugin::WorkAssignment
    self.children.each do |c|
      c.published = self.published
      c.article_privacy_exceptions = self.article_privacy_exceptions
    end
  end

end
