require_dependency 'noosfero'
require 'noosfero/plugin/parent_methods'
require 'noosfero/plugin/hot_spot/definitions'

class Noosfero::Plugin

  attr_accessor :context

  def initialize(context=nil)
    self.context = context
  end

  def environment
    context.send :environment if self.context
  end

  class << self

    include Noosfero::Plugin::ParentMethods

    attr_writer :should_load

    def should_load
      @should_load.nil? && true || @boot
    end

    def initialize!
      return if !should_load

      enabled_plugins_names = available_plugins.map{ |d| File.basename d }
      if (deps_unmet = Noosfero::Plugin::DependencyCalc.deps_unmet(*enabled_plugins_names)).present?
        STDERR.puts "Plugins's dependencies aren't met, please enable the plugins: #{deps_unmet.to_a.join ', '}"
        exit 1
      end

      klasses = available_plugins.map do |plugin_dir|
        plugin_name = File.basename(plugin_dir)
        load_plugin plugin_name
      end
      available_plugins.each do |plugin_dir|
        load_plugin_extensions plugin_dir
      end
      # filters must be loaded after all extensions
      klasses.each do |plugin|
        load_plugin_filters plugin
        load_plugin_hotspots plugin
      end
    end

    def setup(config)
      return if !should_load
      available_plugins.each do |dir|
        setup_plugin(dir, config)
      end
    end

    def setup_plugin(dir, config)
      plugin_name = File.basename(dir)

      plugin_dependencies_ok = true
      plugin_dependencies_file = File.join(dir, 'dependencies.rb')
      if File.exists?(plugin_dependencies_file)
        begin
          require plugin_dependencies_file
        rescue LoadError => ex
          plugin_dependencies_ok = false
          $stderr.puts "W: Noosfero plugin #{plugin_name} failed to load (#{ex})"
        end
      end

      if plugin_dependencies_ok
        %w[
            controllers
            controllers/public
            controllers/profile
            controllers/myprofile
            controllers/admin
        ].each do |folder|
          config.autoload_paths << File.join(dir, folder)
        end
        [ config.autoload_paths, $:].each do |path|
          path << File.join(dir, 'models')
          path << File.join(dir, 'serializers')
          path << File.join(dir, 'lib')
          # load vendor/plugins
          Dir.glob(File.join(dir, '/vendor/plugins/*')).each do |vendor_plugin|
            path << "#{vendor_plugin}/lib"
          end
        end
        Dir.glob(File.join(dir, '/vendor/plugins/*')).each do |vendor_plugin|
          init = "#{vendor_plugin}/init.rb"
          require init.gsub(/.rb$/, '') if File.file? init
        end

        # add view path
        config.paths['app/views'].unshift File.join(dir, 'views')
      end
    end

    def load_plugin_identifier identifier
      klass = identifier.to_s.camelize.constantize
      klass = klass.const_get :Base if klass.class == Module
      klass
    end

    def load_plugin public_name
      load_plugin_identifier "#{public_name.to_s.camelize}Plugin"
    end

    # This is a generic method that initialize any possible filter defined by a
    # plugin to a specific controller
    def load_plugin_filters(plugin)
      ActionDispatch::Reloader.to_prepare do
        filters = plugin.new.send 'application_controller_filters' rescue []
        Noosfero::Plugin.add_controller_filters ApplicationController, plugin, filters

        plugin_methods = plugin.instance_methods.select {|m| m.to_s.end_with?('_filters')}
        plugin_methods.each do |plugin_method|
          controller_class = plugin_method.to_s.gsub('_filters', '').camelize.constantize

          filters = plugin.new.send(plugin_method)
          Noosfero::Plugin.add_controller_filters controller_class, plugin, filters
        end
      end
    end

    # This is a generic method to extend the hotspots list with plugins
    # hotspots. This allows plugins to extend other plugins.
    # To use this, the plugin must define its hotspots inside a module Hotspots.
    # Its also needed to include Noosfero::Plugin::HotSpot module
    # in order to dispatch plugins methods.
    #
    # Checkout FooPlugin for usage example.
    def load_plugin_hotspots(plugin)
      ActionDispatch::Reloader.to_prepare do
        begin
          module_name = "#{plugin.name}::Hotspots"
          Noosfero::Plugin.send(:include, module_name.constantize)
        rescue NameError
        end
      end
    end

    def add_controller_filters(controller_class, plugin, filters)
      unless filters.is_a?(Array)
        filters = [filters]
      end
      filters.each do |plugin_filter|
        plugin_filter[:options] ||= {}
        plugin_filter[:options][:if] = -> { environment.plugin_enabled? plugin.module_name }

        filter_method = "#{plugin.identifier}_#{plugin_filter[:method_name]}".to_sym
        controller_class.send plugin_filter[:type], filter_method, plugin_filter[:options]
        controller_class.send :define_method, filter_method, &plugin_filter[:block]
      end
    end

    def load_plugin_extensions(dir)
      ActionDispatch::Reloader.to_prepare do
        Dir[File.join(dir, 'lib', 'ext', '*.rb')].each{ |file| require_dependency file }
        ActiveSupport.run_load_hooks "#{File.basename dir}_plugin_extensions".to_sym
      end
    end

    def available_plugins
      unless @available_plugins
        path = File.join(Rails.root, '{baseplugins,config/plugins}', '*')
        @available_plugins = Dir.glob(path).sort.select{ |i| File.directory?(i) }
        if Rails.env.test? && !@available_plugins.include?(File.join(Rails.root, 'config', 'plugins', 'foo'))
          @available_plugins << File.join(Rails.root, 'plugins', 'foo')
        end
      end
      @available_plugins
    end

    def available_plugin_names
      available_plugins.map { |f| File.basename(f).camelize }
    end

    def all
      @all ||= available_plugins.map{ |dir| "#{File.basename dir}_plugin".camelize.constantize.to_s }
    end
  end

  def has_block?(block)
    self.extra_blocks.keys.include?(block)
  end

  def expanded_template(file_path, locals = {})
    views_path = Rails.root.join('plugins', "#{self.class.public_name}", 'views')
    ERB.new(File.read("#{views_path}/#{file_path}")).result(binding)
  end

  # Here the developer may specify the events to which the plugins can
  # register and must return true or false. The default value must be false.
  # Must also explicitly define its returning variables.

  # -> If true, noosfero will include plugin_dir/public/style.css into
  # application
  def stylesheet?
    false
  end

  include Noosfero::Plugin::HotSpot::Definitions

end

require 'noosfero/plugin/hot_spot'
require 'noosfero/plugin/manager'
require 'noosfero/plugin/settings'
