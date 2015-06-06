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
      alias_method "original_#{field}", "delegated_#{field}"

      prefix = options[:prefix] || 'default'
      default_field = options[:default_field] || "#{prefix}_#{field}" unless options[:if]

      define_method "#{field}_with_default" do
        apply_default = case condition = options[:if]
        when Proc then instance_exec &condition
        when Symbol then self.send condition
        else
          default = self.send default_field if default_field
          # skip default_if because of infinite loop
          # check if `default` is still nil, can't use || as false is also covered
          default = options[:default] if default.nil?
          default
        end

        # we prefer value from dabatase here, and the getter may give a default value
        # e.g. Product#name default to Product#product_category.name
        own = if field.to_s.in? self.class.column_names then self[field] else self.send "own_#{field}" end
        # blank? also covers false, use nil? and empty?
        if apply_default or own.nil? or (own.respond_to? :empty? and own.empty?)
          self.send "delegated_#{field}"
        else
          own
        end
      end
      define_method "#{field}_with_default=" do |*args|
        if default_field
          # apply default_if in case of a special condition where default is automatically applied
          default = case default_if = options[:default_if]
          when Proc then instance_exec &default_if
          when Symbol then self.send default_if
          # otherwise, the setter automatically disable the default flag
          else false
          end
          self.send "#{default_field}=", default rescue nil
        end

        self.send "own_#{field}=", *args
      end
      alias_method_chain field, :default
      alias_method_chain "#{field}=", :default
      alias_method "own_#{field}", "#{field}_without_default"
      alias_method "own_#{field}=", "#{field}_without_default="

      include DefaultItem::InstanceMethods
    end
  end

  module InstanceMethods
  end

end

ActiveRecord::Base.extend DefaultItem::ClassMethods
