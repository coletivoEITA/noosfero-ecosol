require_dependency 'open_graph_plugin/stories'

module OpenGraphPlugin::AttachStories

  module ClassMethods

    def open_graph_attach_stories
      klass = self.name
      callbacks = OpenGraphPlugin::Stories::ModelStories[klass.to_sym]
      return if callbacks.blank?

      callbacks.each do |on, stories|
        # subclasses may overide this, but the callback is called only once
        method = "open_graph_after_#{on}"
        self.send "after_#{on}", method
        self.send :define_method, method do
          actor = User.current.person rescue nil
          OpenGraphPlugin::Stories.delay.publish self, on, actor, stories if actor
        end
      end
    end

  end

  module InstanceMethods

  end

end
