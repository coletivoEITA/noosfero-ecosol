module ::ActiveRecord

  module AssociationPreload

    module ClassMethods

      def add_preloaded_records_to_collection_with_nil_check parent_records, reflection_name, associated_record
        add_preloaded_records_to_collection_without_nil_check parent_records || [], reflection_name, associated_record
      end
      alias_method_chain :add_preloaded_records_to_collection, :nil_check

    end
  end
end
