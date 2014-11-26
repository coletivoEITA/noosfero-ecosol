
class OpenGraphPlugin::Publisher

  attr_accessor :actions
  attr_accessor :objects

  def initialize attributes = {}
    attributes.each do |attr, value|
      self.send "#{attr}=", value
    end
  end

  def publish on, actor, story_defs, object_data_url
    raise 'abstract method called'
  end

  def publish_stories object_data, on, actor, stories
    stories.each do |story|
      defs = OpenGraphPlugin::Stories::Definitions[story]

      match_criteria = if defs[:criteria] then defs[:criteria].call(object_data) else true end
      next unless match_criteria
      match_condition = if defs[:publish_if] then defs[:publish_if].call(object_data) else true end
      next unless match_condition

      object_data_url = object_data.url
      object_data_url = Noosfero::Application.routes.url_helpers.url_for object_data_url.except(:port) unless object_data_url.is_a? String

      if defs[:tracker]
        exclude_actor = actor
        trackers = OpenGraphPlugin::Track.profile_trackers object_data, exclude_actor
        trackers.each do |tracker|
          publish on, tracker.tracker, defs, object_data_url
        end
      else
        publish on, actor, defs, object_data_url
      end
    end
  end

end

