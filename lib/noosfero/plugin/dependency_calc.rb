#!/usr/bin/env ruby

module Noosfero
  class Plugin
    class DependencyCalc

      ScriptRun = File.basename($0) == File.basename(__FILE__)

      RailsRoot = File.expand_path "#{File.dirname(__FILE__)}/../../../"
      PluginsPath = "#{RailsRoot}/plugins"

      NameProc = proc{ |p| p.to_s.underscore.gsub /_plugin$/, '' }

      SpecFile = 'plugin.yml'

      MessageLevels = {
        :info => 0,
        :warning => 1,
        :fatal => 2,
      }
      Messages = {
        :plugin_not_found => {:type => :fatal, :text => "Can't find %{plugin} plugin!"},
        :spec_not_found => {:type => :warning, :text => "Can't find %{plugin}'s plugin specification. Assuming it doesn't have dependencies."},
        :circular_dependency => {:type => :fatal, :text => "Circular dependency found for %{plugin} plugin!"}
      }

      attr_reader :dependencies
      attr_accessor :log_level
      attr_accessor :plugin

      def initialize plugin = nil, log_level=:warning
        self.plugin = plugin
        self.log_level = log_level
      end

      def self.deps_unmet *plugins
        plugins = plugins.map{ |p| NameProc.call p }
        plugins_without_deps = plugins
        plugins_with_deps = Set.new plugins_without_deps
        calc = self.new
        calc.log_level = :fatal

        plugins.each do |plugin|
          calc.plugin = plugin
          calc.run
          plugins_with_deps += calc.dependencies
        end

        plugins_with_deps.to_a - plugins_without_deps
      end

      def self.deps_met? *plugins
        self.deps_unmet(*plugins).blank?
      end

      def run
        self.plugin = NameProc.call self.plugin
        @dependencies = []

        load_dependencies plugin
        @dependencies -= [plugin]
        @dependencies
      end

      private

      def err plugin, id
        message = Messages[id]
        message_text = I18n.interpolate _(message[:text]), {:plugin => plugin}
        message_level = MessageLevels[message[:type]]
        config_level = MessageLevels[self.log_level]

        if config_level <= message_level
          STDERR.puts "#{message[:type]}: #{message_text}" if ScriptRun
        end

        if message[:type] == :fatal
          if ScriptRun
            exit 1
          else
            raise message_text
          end
        end
      end

      def read_dependencies plugin
        @dependencies_cache ||= {}
        # this avoid double warning print (see below)
        return @dependencies_cache[plugin] if @dependencies_cache[plugin]

        if not File.directory? "#{PluginsPath}/#{plugin}"
          err plugin, :plugin_not_found
        end

        begin
          yml = YAML.load(File.read "#{PluginsPath}/#{plugin}/#{SpecFile}")
        rescue Errno::ENOENT => e
          err plugin, :spec_not_found
          yml = {}
        end

        @dependencies_cache[plugin] = yml['dependencies'].to_a
      end

      def load_dependencies plugin, path = []
        @dependencies << plugin unless @dependencies.include? plugin

        read_dependencies(plugin).each do |dependency|
          if path.include? dependency
            err plugin, :circular_dependency
          end

          load_dependencies dependency, path + [dependency]
        end
      end

      if ScriptRun
        require 'rubygems'
        require 'set'
        require 'yaml'
        require 'active_support/all'
        require 'i18n'
        def _(str); str; end

        plugin = ARGV[0]
        calc = DependencyCalc.new plugin
        calc.run
        puts calc.dependencies.to_a.join ' '
        exit 0
      end

    end
  end
end

