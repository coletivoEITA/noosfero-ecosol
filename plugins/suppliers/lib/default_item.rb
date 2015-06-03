module DefaultItem

  module ClassMethods

    def default_item field, options = {}

      # Rails doesn't define getters for attributes
      define_method field do
        self[field]
      end if field.to_s.in? self.column_names and not method_defined? field
      define_method "#{field}=" do |value|
        self[field] = value
      end if field.to_s.in? self.column_names and not method_defined? "#{field}="

      define_method "delegated_#{field}" do
        delegate_to = options[:delegate_to]
        value = case delegate_to
        when Symbol
          object = self.send delegate_to
          if object then object.send field else self.send "own_#{field}" end rescue nil
        else
          instance_eval &delegate_to
        end
      end

      define_method "#{field}_with_default" do
        apply_default = case condition = options[:if]
        when Proc
          instance_eval &condition
        when Symbol
          self.send condition
        else
          prefix = options[:prefix] || 'default'
          default_field = self.send "#{prefix}_#{field}"
          # check if default_field is nil, can't use || as false will be covered
          default_field = options[:default] if default_field.nil?
          default_field
        end

        own = if self.class.column_names.include?(field) then self[field] else self.send "own_#{field}" end
        if apply_default or own.blank?
          self.send "delegated_#{field}"
        else
          own
        end
      end
      alias_method_chain field, :default

      # aliases for better names
      alias_method "original_#{field}", "delegated_#{field}"
      alias_method "own_#{field}", "#{field}_without_default"
      alias_method "own_#{field}=", "#{field}="


      include DefaultItem::InstanceMethods
    end
  end

  module InstanceMethods
  end

end

ActiveRecord::Base.extend DefaultItem::ClassMethods
