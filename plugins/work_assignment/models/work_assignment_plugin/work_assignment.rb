class WorkAssignmentPlugin::WorkAssignment < Folder

  settings_items :publish_submissions, type: :boolean, default: false
  settings_items :default_email, type: :string, default: ""
  settings_items :allow_visibility_edition, type: :boolean, default: false

  attr_accessible :publish_submissions
  attr_accessible :default_email
  attr_accessible :allow_visibility_edition

  def self.icon_name(article = nil)
    'work-assignment'
  end

  def self.short_description
    _('Work Assignment')
  end

  def self.description
    _('Defines a work to be done by the members and receives their submissions about this work.')
  end

  def self.versioned_name(submission, folder)
    "(V#{folder.children.count + 1}) #{submission.name}"
  end

  def accept_comments?
    true
  end

  def allow_create?(user)
    profile.members.include?(user)
  end

  def to_html(options = {})
    lambda do
      render template: 'content_viewer/work_assignment'
    end
  end

  def find_or_create_author_folder author
    if defined? TeamsPlugin and team = self.teams.joins(:profiles).where(profiles: {id: author.id}).first
      slug = "team-#{team.id}"
      klass = TeamsPlugin::TeamFolder
      attributes = {team: team}
    else
      slug = author.name.to_slug
      klass = Folder
      attributes = {name: author.name}
    end
    folder = self.children.where(slug: slug).first
    folder ||= klass.create! attributes.merge(parent: self, profile: profile, author: author, published: publish_submissions), without_protection: true
  end

  def folders
    @folders ||= self.children.order('name ASC').all
  end

  def submissions
    children.map(&:children).flatten.compact
  end

  def submissions_as_json user
    h = {}; self.folders.each do |author_folder|
      h[author_folder.id] = author_folder.children.order('created_at DESC').map do |s|
        WorkAssignmentPlugin::SubmissionSerializer.new(s).attributes
      end
    end
    h
  end

  def cacheable?
    false
  end

end
