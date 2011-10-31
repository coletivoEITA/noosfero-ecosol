module DefaultItem
  module ClassMethods
    def default_item(field, options = {})

      define_method "original_#{field}" do
        delegate_to = options[:delegate_to]
        if delegate_to.is_a?(Symbol)
          d = send(delegate_to)
          d ? d.send(field) : send("own_#{field}")
        else
          instance_eval(&delegate_to)
        end
      end
      define_method "#{field}_with_default" do
        send(options[:if] || "default_#{field}") ? send("original_#{field}") : send("own_#{field}")
      end

      class_eval <<-CODE
        def #{field}
          self["#{field}"]
        end unless self.new.respond_to?("#{field}")
        def #{field}=(value)
          self["#{field}"] = value
        end unless self.new.respond_to?("#{field}=")

        def #{field}_with_default=(value)
        end
        alias_method_chain :#{field}, :default
        alias_method_chain :#{field}=, :default
        alias_method :own_#{field}, :#{field}_without_default
        alias_method :own_#{field}=, :#{field}_without_default=

        alias_method :#{field}, :#{field}_with_default
        alias_method :#{field}=, :#{field}_without_default=
      CODE

      include DefaultItem::InstanceMethods
    end
  end

  module InstanceMethods
  end
end

ActiveRecord::Base.extend DefaultItem::ClassMethods
