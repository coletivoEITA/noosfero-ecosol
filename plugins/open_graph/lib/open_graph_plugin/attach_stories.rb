require_dependency 'open_graph_plugin/stories'

module OpenGraphPlugin::AttachStories

  module ClassMethods

    def open_graph_attach_stories
      klass = self.name
      stories = OpenGraphPlugin::Stories::ModelStories[klass.to_sym]
      return if stories.blank?

      callbacks = stories.map do |story|
        definition = OpenGraphPlugin::Stories::Definitions[story]
        definition[:on]
      end.flatten.compact.uniq

      callbacks.each do |on|
        # subclasses may overide this, but the callback is called only once
        method = "open_graph_after_#{on}"
        self.send "after_#{on}", method
        self.send :define_method, method do
          actor = User.current.person rescue nil
          OpenGraphPlugin::Stories.delay.publish self, actor, stories if actor
        end
      end
    end

  end

  module InstanceMethods

  end

end
