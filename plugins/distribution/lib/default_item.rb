module DefaultItem
  module ClassMethods
    def default_item(field, options = {})
      class_eval <<-CODE
        def own_#{field}
          self["#{field}"]
        end
        def own_#{field}=(value)
          self["#{field}"] = value
        end
      CODE

      define_method field do
        if send(options[:if] || "default_#{field}")
          delegate_to = options[:delegate_to]
          if delegate_to.is_a?(Symbol)
            i = send(delegate_to)
            i ? i.send(field) : send("own_#{field}")
          else
            instance_eval(&delegate_to)
          end
        else
          send("own_#{field}")
        end
      end

      include DefaultItem::InstanceMethods
    end
  end

  module InstanceMethods
  end
end

ActiveRecord::Base.extend DefaultItem::ClassMethods
