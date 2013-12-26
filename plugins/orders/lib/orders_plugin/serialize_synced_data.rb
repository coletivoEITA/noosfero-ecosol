module OrdersPlugin::SerializedSyncedData

  module ClassMethods
    def sync_serialized_field field
      serialize "#{field}_data", Hash

      before_create "sync_#{field}_data"
      define_method "sync_#{field}_data" do
        source = self.send field
        if source.is_a? ActiveRecord::Base
          data = if block_given? then yield source else source.attributes end
          self.send "#{field}_data=", data if self.send("#{field}_data").blank?
        end
      end

      include InstanceMethods
    end
  end

  module InstanceMethods
  end

end
