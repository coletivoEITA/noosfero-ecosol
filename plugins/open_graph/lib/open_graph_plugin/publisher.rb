
class OpenGraphPlugin::Publisher

  attr_accessor :actions
  attr_accessor :objects

  def self.default
    @default ||= self.new
  end

  def self.profile_from_object_data object_data
    case object_data
    when Profile
      profile = object_data
    else
      profile = object_data.profile rescue nil
    end
  end

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

    print_debug "open_graph: publish_story #{story}" if debug? actor
    match_criteria = if criteria = defs[:criteria] then criteria.call(object_data, actor) else true end
    return unless match_criteria
    print_debug "open_graph: #{story} match criteria" if debug? actor
    match_condition = if publish_if = defs[:publish_if] then publish_if.call(object_data, actor) else true end
    return unless match_condition
    print_debug "open_graph: #{story} match publish_if" if debug? actor

    actors = self.story_trackers defs, actor, object_data
    return if actors.blank?
    print_debug "open_graph: #{story} has enabled trackers" if debug? actor

    begin
      if publish = defs[:publish]
        publish.call actor, object_data, self
      else
        object_data_url = if object_data_url = defs[:object_data_url] then object_data_url.call(object_data) else object_data.url end
        object_data_url = self.url_for object_data_url

        actors.each do |actor|
          self.publish actor, defs, object_data_url
        end
      end
    rescue => e
      print_debug "open_graph: can't publish story: #{e.message}" if debug? actor
    end
  end

  def story_trackers story_defs, actor, object_data
    trackers = []

    track_configs = Array[story_defs[:track_config]].compact.map(&:constantize)
    return if track_configs.empty?

    profile = self.class.profile_from_object_data object_data
    passive = story_defs[:passive]
    if passive
      track_configs.each do |c|
        trackers.concat c.trackers_of_profile(profile)
      end.flatten

      trackers.select! do |t|
        track_configs.any?{ |c| c.enabled_for self.context, t }
      end
    else #active
      match_track = profile.person? and track_configs.any? do |c|
        c.enabled_for(self.context, actor) and
          actor.send("open_graph_#{c.track_name}_track_configs").where(object_type: story_defs[:object_type]).first
      end
      trackers << actor if match_track
    end

    trackers
  end

  protected

  def context
    :open_graph
  end

  def print_debug msg
    puts msg
    Delayed::Worker.logger.debug msg
  end
  def debug? actor=nil
    false
  end

end

