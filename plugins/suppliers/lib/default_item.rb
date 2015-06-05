module DefaultItem

  module ClassMethods

    def default_item field, options = {}

      default_trigger_attr = "#{field}_default_trigger_attr"

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

      define_method default_trigger_attr do
        return if options[:if]
        prefix = options[:prefix] || 'default'
        "#{prefix}_#{field}"
      end

      define_method "#{field}_with_default" do
        apply_default = case condition = options[:if]
        when Proc
          instance_eval &condition
        when Symbol
          self.send condition
        else
          default = self.send self.send(default_trigger_attr)
          # check if `default` is still nil, can't use || as false is also covered
          default = options[:default] if default.nil?
          default
        end

        # we prefer value from dabatase here, and the getter may give a default value
        # e.g. Product#name default to Product#product_category.name
        own = if field.to_s.in? self.class.column_names then self[field] else self.send "own_#{field}" end
        if apply_default or own.blank?
          self.send "delegated_#{field}"
        else
          own
        end
      end
      define_method "#{field}_with_default=" do |*args|
        # the setter automatically disable the default flag
        self.send "#{self.send default_trigger_attr}=", false rescue nil
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
