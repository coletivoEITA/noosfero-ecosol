module ActsAsHavingSettings
  module DefaultItem
    module ClassMethods
      def settings_default_item field, options, &block
        extend ActsAsHavingSettings::ClassMethods
        extend ::DefaultItem::ClassMethods

        settings_items "default_#{field}", :default => options[:default], :type => options[:type]
        default_item field, options

        include ActsAsHavingSettings::DefaultItem::InstanceMethods
      end
    end

    module InstanceMethods
    end
  end
end

ActiveRecord::Base.extend ActsAsHavingSettings::DefaultItem::ClassMethods
