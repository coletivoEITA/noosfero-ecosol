# monkey patch rails 3.2.21 methods to support ruby 2.2
# Basically change reflection = reflection to reflection = self.reflection

if RUBY_VERSION >= '2.2.0'

module ActiveRecord
  # = Active Record Has Many Association
  module Associations
    # This is the proxy that handles a has many association.
    #
    # If the association has a <tt>:through</tt> option further specialization
    # is provided by its child HasManyThroughAssociation.
    class HasManyAssociation < CollectionAssociation #:nodoc:
      def has_cached_counter?(reflection = self.reflection)
        owner.attribute_present?(cached_counter_attribute_name(reflection))
      end

      def cached_counter_attribute_name(reflection = self.reflection)
        "#{reflection.name}_count"
      end

      def update_counter(difference, reflection = self.reflection)
        if has_cached_counter?(reflection)
          counter = cached_counter_attribute_name(reflection)
          owner.class.update_counters(owner.id, counter => difference)
          owner[counter] += difference
          owner.changed_attributes.delete(counter) # eww
        end
      end

      # This shit is nasty. We need to avoid the following situation:
      #
      #   * An associated record is deleted via record.destroy
      #   * Hence the callbacks run, and they find a belongs_to on the record with a
      #     :counter_cache options which points back at our owner. So they update the
      #     counter cache.
      #   * In which case, we must make sure to *not* update the counter cache, or else
      #     it will be decremented twice.
      #
      # Hence this method.
      def inverse_updates_counter_cache?(reflection = self.reflection)
        counter_name = cached_counter_attribute_name(reflection)
        reflection.klass.reflect_on_all_associations(:belongs_to).any? { |inverse_reflection|
          inverse_reflection.counter_cache_column == counter_name
        }
      end
    end
  end
end

end
