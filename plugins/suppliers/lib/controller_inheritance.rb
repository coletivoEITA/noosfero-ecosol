# FIXME: from rails 3
class Class
  # Declare a class-level attribute whose value is inheritable by subclasses.
  # Subclasses can change their own value and it will not impact parent class.
  #
  #   class Base
  #     class_attribute :setting
  #   end
  #
  #   class Subclass < Base
  #   end
  #
  #   Base.setting = true
  #   Subclass.setting            # => true
  #   Subclass.setting = false
  #   Subclass.setting            # => false
  #   Base.setting                # => true
  #
  # In the above case as long as Subclass does not assign a value to setting
  # by performing <tt>Subclass.setting = _something_ </tt>, <tt>Subclass.setting</tt>
  # would read value assigned to parent class. Once Subclass assigns a value then
  # the value assigned by Subclass would be returned.
  #
  # This matches normal Ruby method inheritance: think of writing an attribute
  # on a subclass as overriding the reader method. However, you need to be aware
  # when using +class_attribute+ with mutable structures as +Array+ or +Hash+.
  # In such cases, you don't want to do changes in places but use setters:
  #
  #   Base.setting = []
  #   Base.setting                # => []
  #   Subclass.setting            # => []
  #
  #   # Appending in child changes both parent and child because it is the same object:
  #   Subclass.setting << :foo
  #   Base.setting               # => [:foo]
  #   Subclass.setting           # => [:foo]
  #
  #   # Use setters to not propagate changes:
  #   Base.setting = []
  #   Subclass.setting += [:foo]
  #   Base.setting               # => []
  #   Subclass.setting           # => [:foo]
  #
  # For convenience, a query method is defined as well:
  #
  #   Subclass.setting?       # => false
  #
  # Instances may overwrite the class value in the same way:
  #
  #   Base.setting = true
  #   object = Base.new
  #   object.setting          # => true
  #   object.setting = false
  #   object.setting          # => false
  #   Base.setting            # => true
  #
  # To opt out of the instance reader method, pass :instance_reader => false.
  #
  #   object.setting          # => NoMethodError
  #   object.setting?         # => NoMethodError
  #
  # To opt out of the instance writer method, pass :instance_writer => false.
  #
  #   object.setting = false  # => NoMethodError
  def class_attribute(*attrs)
    options = attrs.extract_options!
    instance_reader = options.fetch(:instance_reader, true)
    instance_writer = options.fetch(:instance_writer, true)

    attrs.each do |name|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{name}() nil end
        def self.#{name}?() !!#{name} end

        def self.#{name}=(val)
          singleton_class.class_eval do
            remove_possible_method(:#{name})
            define_method(:#{name}) { val }
          end

          if singleton_class?
            class_eval do
              remove_possible_method(:#{name})
              def #{name}
                defined?(@#{name}) ? @#{name} : singleton_class.#{name}
              end
            end
          end
          val
        end

        if instance_reader
          remove_possible_method :#{name}
          def #{name}
            defined?(@#{name}) ? @#{name} : self.class.#{name}
          end

          def #{name}?
            !!#{name}
          end
        end
      RUBY

      attr_writer name if instance_writer
    end
  end

  private
  def singleton_class?
    ancestors.first != self
  end
end

module ControllerInheritance

  module ClassMethods

    def hmvc context
      cattr_accessor :hmvc_paths
      class_attribute :inherit_templates
      class_attribute :hmvc_inheritable
      class_attribute :hmvc_context

      self.before_filter :set_hmvc_context

      self.inherit_templates = true
      self.hmvc_inheritable = true
      self.hmvc_context = context
      self.hmvc_paths ||= {}
      self.hmvc_paths[self.hmvc_context] ||= {} if self.hmvc_context

      # initialize other context's controllers paths
      controllers = [self] + context.controllers.map{ |controller| controller.constantize }

      controllers.each do |klass|
        context_klass = klass
        while ((klass = klass.superclass).hmvc_inheritable rescue false)
          self.hmvc_paths[self.hmvc_context][klass.controller_path] = context_klass.controller_path
        end
      end

      include InstanceMethods
    end

    def hmvc_controller_path hmvc_context = self.hmvc_context
      self.hmvc_paths[hmvc_context][self.controller_path] || self.controller_path
    end

    protected

  end

  class ActionView < ActionView::Base

    private

    def _pick_partial_template_with_hmvc partial_path
      if partial_path.include? '/'
        _pick_partial_template_without_hmvc partial_path
      elsif controller
        controller.send :each_template_with_hmvc do |klass|
          begin
            self.view_paths.find_template "#{klass.controller_path}/_#{partial_path}", self.template_format
          rescue ::ActionView::MissingTemplate => e
            raise "Can't find '#{partial_path}' partial in any #{controller.class}'s parent" unless (klass.inherit_templates rescue nil)
          end
        end
      else
        _pick_partial_template_without_hmvc partial_path
      end
    end
    alias_method_chain :_pick_partial_template, :hmvc

  end

  module InstanceMethods

    protected

    def set_hmvc_context
      @hmvc_context = self.class.hmvc_context
    end

    # replace method just to change instance class
    def initialize_template_class response
      response.template = ControllerInheritance::ActionView.new self.class.view_paths, {}, self
      response.template.helpers.send :include, self.class.master_helper_module
      response.redirected_to = nil
      @performed_render = @performed_redirect = false
    end

    def default_template action_name = self.action_name
      @template_html_fallback = (request.format == :all or request.format == :html) if @template_html_fallback.nil?

      self.each_template_with_hmvc do |klass|
        begin
          self.view_paths.find_template "#{klass.controller_path}/#{action_name}", default_template_format, @template_html_fallback
        rescue ::ActionView::MissingTemplate => e
          # raise the same exception as rails will rescue it
          raise e unless (klass.inherit_templates rescue false)
        end
      end
    end

    def url_for options = {}
      controller = options[:controller]
      controller ||= controller_path
      controller = controller.to_s

      dest_controller = self.class.hmvc_paths[@hmvc_context][controller] rescue nil
      dest_controller ||= options[:controller] || self.controller_path
      options[:controller] = dest_controller

      super options
    end

    def each_template_with_hmvc &block
      klass = self.class
      begin
        next if @hmvc_skip_templates_for.to_a.include? klass

        ret = yield klass
        return ret if ret
      end while klass = klass.superclass
    end

  end

end
