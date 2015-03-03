
class OpenGraphPlugin::Publisher

  attr_accessor :actions
  attr_accessor :objects

  def initialize attributes = {}
    attributes.each do |attr, value|
      self.send "#{attr}=", value
    end
  end

  def publish actor, story_defs, object_data_url
    raise 'abstract method called'
  end

  def url_for url
    return url if url.is_a? String
    Noosfero::Application.routes.url_helpers.url_for url.except(:port)
  end

  def publish_stories object_data, actor, stories
    stories.each do |story|
      self.publish_story object_data, actor, story
    end
  end

  def publish_story object_data, actor, story
    defs = OpenGraphPlugin::Stories::Definitions[story]
    passive = defs[:passive]
    actors = []

    match_criteria = if criteria = defs[:criteria] then criteria.call(object_data, actor) else true end
    return unless match_criteria
    match_condition = if publish_if = defs[:publish_if] then publish_if.call(object_data, actor) else true end
    return unless match_condition

    track_configs = Array[defs[:track_config]].compact.map(&:constantize)
    return if track_configs.empty?
    if passive
      exclude_actor = actor
      trackers = []; track_configs.each do |c|
        trackers.concat c.trackers(object_data, exclude_actor)
      end.flatten

      trackers.select! do |t|
        track_configs.any?{ |c| c.enabled_for self.context, t }
      end

      return if trackers.empty?
      actors = trackers
    else #active
      match_track = track_configs.any? do |c|
        c.enabled_for(self.context, actor) and
          actor.send("open_graph_#{c.track_name}_track_configs").where(object_type: defs[:object_type]).first
      end

      return unless match_track
      actors << actor
    end

    if publish = defs[:publish]
      publish.call actor, object_data, self
    else
      object_data_url = if object_data_url = defs[:object_data_url] then object_data_url.call(object_data) else object_data.url end
      object_data_url = self.url_for object_data_url

      #begin
      actors.each do |actor|
        self.publish actor, defs, object_data_url
      end
      #rescue => e
      #Delayed::Worker.logger.debug "can't publish story: #{e.message}"
      # continue to other stories
      #end
    end
  end

  def context
    :open_graph
  end

end

