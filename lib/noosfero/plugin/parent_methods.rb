class Noosfero::Plugin

  # Plugins that are defined as modules should extend this module
  # For example:
  #   module MyPlugin
  #     extend Noosfero::Plugin::ParentMethods
  #   end
  module ParentMethods

    # Called for each ActiveRecord class with parents
    # See http://apidock.com/rails/ActiveRecord/ModelSchema/ClassMethods/full_table_name_prefix
    def table_name_prefix
      @table_name_prefix ||= "#{self.name.underscore}_"
    end

  end

end
