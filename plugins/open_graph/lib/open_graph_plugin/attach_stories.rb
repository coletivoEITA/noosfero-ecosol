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
        if Rails.env.development?
          # on development, crash on errors
          self.send "after_#{on}", method
        else
          self.send "after_commit", method, on: on
        end

        self.send :define_method, method do
          actor = User.current.person rescue nil
          klass = OpenGraphPlugin::Stories
          # on development, crash on errors
          klass = klass.delay unless Rails.env.development?

          klass.publish self, on, actor, stories if actor
        end
      end
    end

  end

  module InstanceMethods

  end

end
