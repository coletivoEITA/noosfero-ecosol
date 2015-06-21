module DefaultDelegate

  module ClassMethods

    def default_delegate_setting field, options, &block
      extend ActsAsHavingSettings::ClassMethods

      prefix = options[:prefix] || :default
      default_field = "#{prefix}_#{field}"
      settings_items default_field, default: options[:default], type: :boolean

      options[:default_field] = default_field
      default_delegate field, options
    end

    # TODO: add some documentation about the methods being added
    def default_delegate field, options = {}
      # rake db:migrate run?
      return unless self.table_exists?

      # Rails doesn't define getters for attributes
      define_method field do
        self[field]
      end if field.to_s.in? self.column_names and not self.method_defined? field
      define_method "#{field}=" do |value|
        self[field] = value
      end if field.to_s.in? self.column_names and not self.method_defined? "#{field}="

      original_field_method = "original_own_#{field}".freeze
      alias_method original_field_method, field
      own_field = "own_#{field}".freeze
      define_method own_field do
        # we prefer the value from dabatase here, and the getter may give a default value
        # e.g. Product#name defaults to Product#product_category.name
        if field.to_s.in? self.class.column_names then self[field] else self.send original_field_method end
      end
      alias_method "#{own_field}=", "#{field}="

      delegated_field = "delegated_#{field}".freeze
      to = options[:to].freeze
      define_method delegated_field do
        case to
        when Symbol
          object = self.send to
          object.send field if object and object.respond_to? field
        when Proc then instance_exec &to
        end
      end
      alias_method "original_#{field}", delegated_field

      own_field_blank = "own_#{field}_blank?".freeze
      define_method own_field_blank do
        own = self.send own_field
        # blank? also covers false, use nil? and empty? instead
        # having the same value as the delegated is also considered blank
        (own.nil? or (own.respond_to? :empty? and own.empty?)) or own == self.send(delegated_field)
      end
      own_field_present = "own_#{field}_present?".freeze
      define_method own_field_present do
        not self.send own_field_blank
      end
      default_if = options[:default_if].freeze
      own_field_is_default = "own_#{field}_default?".freeze
      define_method own_field_is_default do
        default = self.send own_field_blank
        default ||= case default_if
        when Proc then instance_exec &default_if
        when Symbol then self.send default_if
        else false
        end
      end

      default_field = options[:default_field] || "#{options[:prefix] || :default}_#{field}"
      # as a field may use other field's default_field, check for definition
      default_field_with_presence = "#{default_field}_with_presence".freeze
      unless self.method_defined? default_field_with_presence
        define_method default_field_with_presence do
          original_setting = self.send "#{default_field}_without_presence"
          # if the setting is false, see if it should be true; if it is true, respect it.
          original_setting = self.send own_field_is_default unless original_setting
          original_setting
        end
        define_method "#{default_field_with_presence}=" do |value|
          # this ensures that latter the getter won't
          self.send "#{own_field}=", nil if value
          self.send "#{default_field}_without_presence=", value
        end
        alias_method_chain default_field, :presence
        alias_method_chain "#{default_field}=", :presence
      end

      define_method "#{field}_with_default" do
        if self.send default_field then self.send delegated_field else self.send own_field end
      end
      define_method "#{field}_with_default=" do |*args|
        own = self.send "#{own_field}=", *args
        # break/set the default setting automatically, used for interfaces
        # that don't have the default setting (e.g. manage_products)
        self.send "#{default_field}=", self.send(own_field_is_default)
        own
      end
      alias_method_chain field, :default
      alias_method_chain "#{field}=", :default

      include DefaultDelegate::InstanceMethods
    end
  end

  module InstanceMethods
  end

end

ActiveRecord::Base.extend DefaultDelegate::ClassMethods
