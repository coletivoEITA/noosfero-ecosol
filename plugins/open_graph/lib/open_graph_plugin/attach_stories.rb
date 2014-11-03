require_dependency 'open_graph_plugin/stories'

module OpenGraphPlugin::AttachStories

  module ClassMethods

    def open_graph_attach_stories
      klass = self.name
      events = OpenGraphPlugin::Stories::Spec[klass.to_sym]
      return if events.blank?
      events.each do |on, handler|
        story_method = "on_#{klass.underscore}_#{on}"
        # subclasses may overide this, but the callback is called only once
        method = "open_graph_after_#{on}"

        self.send "after_#{on}", method
        self.send :define_method, method do
          actor = User.current.person rescue nil
          OpenGraphPlugin::Stories.delay.call_hooks self, actor, story_method if actor
        end
      end
    end

  end

  module InstanceMethods

  end

end
