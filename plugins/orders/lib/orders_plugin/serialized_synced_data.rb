module OrdersPlugin::SerializedSyncedData

  module ClassMethods

    def sync_serialized_field field
      cattr_accessor :serialized_synced_fields
      self.serialized_synced_fields ||= []
      self.serialized_synced_fields << field

      serialize "#{field}_data", Hash

      before_create "sync_#{field}_data"
      define_method "sync_#{field}_data" do
        source = self.send field
        if source.is_a? Array or source.is_a? ActiveRecord::Base
          data = if block_given? then yield source else source.attributes end
          self.send "#{field}_data=", data if self.send("#{field}_data").blank?
          data
        end
      end

      include InstanceMethods
    end

  end

  module InstanceMethods

      def sync_serialized_data
        self.class.serialized_synced_fields.each do |field|
          self.send "sync_#{field}_data"
        end
      end

  end

end
