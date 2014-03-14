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

      # create method for the chain
      define_method "#{field}_data" do
        self["#{field}_data"] || {}
      end unless self.respond_to? "#{field}_data"

      # return data from foreign registry if any data was synced yet
      define_method "#{field}_data_with_sync" do
        current_data = self.send "#{field}_data_without_sync"
        if current_data.present? then current_data else self.send("#{field}_synced_data") end
      end
      alias_method_chain "#{field}_data", :sync

      # get the data to sync as defined
      define_method "#{field}_synced_data" do
        source = self.send field
        if block_given?
          data = yield source
        elsif source.is_a? ActiveRecord::Base
          data = SerializedSyncedData.symbolize_keys source.attributes
        elsif source.is_a? Array
          data = source.map{ |source| SerializedSyncedData.symbolize_keys source.attributes }
        end || {}
      end

      define_method "sync_#{field}_data" do
        value = self.send "#{field}_synced_data"
        self.send "#{field}_data=", value if value.present?
      end

      before_create "fill_#{field}_data"
      define_method "fill_#{field}_data" do
        self.send "sync_#{field}_data" if self.send("#{field}_data").blank?
      end

      before_update "sync_#{field}_data"

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
