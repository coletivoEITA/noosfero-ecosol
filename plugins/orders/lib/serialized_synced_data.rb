module SerializedSyncedData

  def self.symbolize_keys hash
    hash = hash.dup; hash.each do |key, value|
      hash.delete key
      hash[key.to_sym] = value
    end
    hash
  end

  module ClassMethods

    def sync_serialized_field field
      cattr_accessor :serialized_synced_fields
      self.serialized_synced_fields ||= []
      self.serialized_synced_fields << field

      serialize "#{field}_data"

      define_method "sync_#{field}_data" do
        source = self.send field
        if block_given?
          data = yield source
        elsif source.is_a? ActiveRecord::Base
          data = SerializedSyncedData.symbolize_keys source.attributes
        elsif source.is_a? Array
          data = source.map{ |source| SerializedSyncedData.symbolize_keys source.attributes }
        end
        self.send "#{field}_data=", data
      end

      before_create "fill_#{field}_data"
      define_method "fill_#{field}_data" do
        self.send "sync_#{field}_data" if self.send("#{field}_data").blank?
      end

      before_update "update_#{field}_data"
      define_method "update_#{field}_data" do
        self.send "sync_#{field}_data"
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
