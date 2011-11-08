module UnscopedGetter
  module ClassMethods
    def unscoped_getter(method, klass)
      define_method "#{method}_with_unscoped" do
        klass.send :with_exclusive_scope do
          send "#{method}_without_unscoped"
        end
      end
      alias_method_chain method, :unscoped
    end
  end
end

ActiveRecord::Base.extend UnscopedGetter::ClassMethods
