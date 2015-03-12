
class OpenGraphPlugin::Publisher

  attr_accessor :actions
  attr_accessor :objects

  def self.default
    @default ||= self.new
  end

  def initialize attributes = {}
    # defaults
    self.actions = OpenGraphPlugin::Stories::DefaultActions
    self.objects = OpenGraphPlugin::Stories::DefaultObjects

    attributes.each do |attr, value|
      self.send "#{attr}=", value
    end
  end

  def publish actor, story_defs, object_data_url
    raise 'abstract method called'
  end

  def url_for url, extra_params={}
    return url if url.is_a? String
    url.delete :port
    url.merge! extra_params
    Noosfero::Application.routes.url_helpers.url_for url
  end

  def passive_url_for url, story_defs
    object_type = self.objects[story_defs[:object_type]]
    url_for url, og_type: MetadataPlugin.og_types[object_type]
  end

  def publish_stories object_data, actor, stories
    stories.each do |story|
      self.publish_story object_data, actor, story
    end
  end

  def publish_story object_data, actor, story
    OpenGraphPlugin.context = self.context
    defs = OpenGraphPlugin::Stories::Definitions[story]
    passive = defs[:passive]

    print_debug "open_graph: publish_story #{story}" if debug? actor
    match_criteria = if (ret = self.call defs[:criteria], object_data, actor).nil? then true else ret end
    return unless match_criteria
    print_debug "open_graph: #{story} match criteria" if debug? actor
    match_condition = if (ret = self.call defs[:publish_if], object_data, actor).nil? then true else ret end
    return unless match_condition
    print_debug "open_graph: #{story} match publish_if" if debug? actor

    actors = self.story_trackers defs, actor, object_data
    return if actors.blank?
    print_debug "open_graph: #{story} has enabled trackers" if debug? actor

    begin
      if publish = defs[:publish]
        instance_exec actor, object_data, &publish
      else
        object_data_url = if (object_data_url = self.call defs[:object_data_url], object_data, actor) then object_data_url else object_data.url end
        object_data_url = if passive then self.passive_url_for object_data_url, defs else self.url_for object_data_url end

        actors.each do |actor|
          print_debug "open_graph: start publishing" if debug? actor
          self.publish actor, defs, object_data_url
        end
      end
    rescue => e
      print_debug "open_graph: can't publish story: #{e.message}" if debug? actor
    end
  end

  def story_trackers story_defs, actor, object_data
    passive = story_defs[:passive]
    trackers = []

    track_configs = Array[story_defs[:track_config]].compact.map(&:constantize)
    return if track_configs.empty?

    if passive
      object_profile = self.call(story_defs[:object_profile], object_data) || object_data.profile rescue nil
      return unless object_profile

      track_configs.each do |c|
        trackers.concat c.trackers_to_profile(object_profile)
      end.flatten

      trackers.select! do |t|
        track_configs.any?{ |c| c.enabled? self.context, t }
      end
    else #active
      object_actor = self.call(story_defs[:object_actor], object_data) || object_data.profile rescue nil
      return unless object_actor and object_actor.person?
      custom_actor = self.call(story_defs[:custom_actor], object_data)
      actor = custom_actor if custom_actor

      match_track = track_configs.any? do |c|
        c.enabled?(self.context, actor) and
          actor.send("open_graph_#{c.track_name}_track_configs").where(object_type: story_defs[:object_type]).first
      end
      trackers << actor if match_track
    end

    trackers
  end

  protected

  def call p, *args
    p and instance_exec *args, &p
  end

  def context
    :open_graph
  end

  def print_debug msg
    puts msg
    Delayed::Worker.logger.debug msg
  end
  def debug? actor=nil
    !Rails.env.production?
  end

end

