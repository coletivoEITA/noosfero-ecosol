require_dependency 'profile_activity'

class ProfileActivity

  after_create :open_graph_publish

  def open_graph_publish
    if self.activity.is_a? ActionTracker::Record
      verb = self.activity.verb.to_sym
      return unless object = self.activity.target
      return unless stories = OpenGraphPlugin::Stories::TrackerStories[verb]
      OpenGraphPlugin::Stories.publish object, stories
    end
  end

end

