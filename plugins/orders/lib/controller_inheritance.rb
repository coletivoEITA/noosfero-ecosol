module ControllerInheritance

  module ClassMethods

    def hmvc context, options = {}
      class_attribute :inherit_templates
      class_attribute :hmvc_inheritable
      class_attribute :hmvc_context
      # FIXME use class_attribute but calculate using all paths
      cattr_accessor :hmvc_paths

      self.inherit_templates = true
      self.hmvc_inheritable = true
      self.hmvc_context = context
      self.hmvc_paths ||= {}

      class_attribute :hmvc_orders_context
      self.hmvc_orders_context = options[:orders_context] || self.superclass.hmvc_orders_context rescue nil

      # initialize other context's controllers paths
      controllers = [self] + context.controllers.map{ |controller| controller.constantize }

      controllers.each do |klass|
        context_klass = klass
        while ((klass = klass.superclass).hmvc_inheritable rescue false)
          self.hmvc_paths[klass.controller_path] ||= context_klass.controller_path
        end
      end

      include InstanceMethods
      helper ViewHelper
    end

    protected

  end

  module InstanceMethods
  end

  module ViewHelper

    def url_for options = {}
      return super unless options.is_a? Hash

      controller = options[:controller]
      controller ||= controller_path
      controller = controller.to_s

      dest_controller = self.controller.hmvc_paths[controller]
      dest_controller ||= options[:controller] || self.controller_path
      options[:controller] = dest_controller

      super
    end

  end

end
