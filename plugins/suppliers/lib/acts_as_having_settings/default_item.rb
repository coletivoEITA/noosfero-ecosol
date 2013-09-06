module ActsAsHavingSettings
  module DefaultItem
    module ClassMethods
      def settings_default_item(field, options, &block)
        extend ActsAsHavingSettings::ClassMethods
        extend ::DefaultItem::ClassMethods

        soptions = {}
        soptions[:default] = options.delete(:default)
        soptions[:type] = options.delete(:type)
        settings_items "default_#{field}".to_sym, soptions

        default_item field, options

        include ActsAsHavingSettings::DefaultItem::InstanceMethods
      end
    end

    module InstanceMethods
    end
  end
end

ActiveRecord::Base.extend ActsAsHavingSettings::DefaultItem::ClassMethods
