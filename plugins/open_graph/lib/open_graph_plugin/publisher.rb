
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
      defs = OpenGraphPlugin::Stories::Definitions[story]

      match_criteria = if criteria = defs[:criteria] then criteria.call(object_data) else true end
      next unless match_criteria
      match_condition = if publish_if = defs[:publish_if] then publish_if.call(object_data) else true end
      next unless match_condition
      # HANDLE passive stories
      match_track = actor.open_graph_track_configs.where(object_type: defs[:object_type]).count > 0
      next unless match_track

      if publish = defs[:publish]
        publish.call actor, object_data, self
      else
        object_data_url = if object_data_url = defs[:object_data_url] then object_data_url.call(object_data) else object_data.url end
        object_data_url = self.url_for object_data_url

        #begin
          if defs[:tracker]
            exclude_actor = actor
            trackers = OpenGraphPlugin::Track.profile_trackers object_data, exclude_actor
            trackers.each do |tracker|
              self.publish tracker.tracker, defs, object_data_url
            end
          else
            self.publish actor, defs, object_data_url
          end
        #rescue => e
          #Delayed::Worker.logger.debug "can't publish story: #{e.message}"
          # continue to other stories
        #end
      end
    end
  end

end

