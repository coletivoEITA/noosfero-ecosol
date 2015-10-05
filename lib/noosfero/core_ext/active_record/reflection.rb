
# on STI classes tike Article and Profile, plugins' extensions
# on associations should be reflected on descendants
module ActiveRecord
  module Reflection

    def self.add_reflection(ar, name, reflection)
      ar._reflections = ar._reflections.merge(name.to_s => reflection)
      ar.descendants.each do |k|
        k._reflections.merge!(name.to_s => reflection)
      end if ar.base_class == ar
    end

  end
end
