module SerializedSyncedData

  def self.symbolize_keys _hash
    hash = {}; _hash.each do |key, value|
      hash[key.to_sym] = value
    end
    hash
  end

  module ClassMethods

    def sync_serialized_field field
      cattr_accessor :serialized_synced_fields
      self.serialized_synced_fields ||= []
      self.serialized_synced_fields << field
      field_data = "#{field}_data".to_sym

      serialize field_data

      # Rails doesn't define getters for attributes
      if field_data.to_s.in? self.column_names and not method_defined? field_data
        define_method field_data do
          self[field_data] || {}
        end
      else
        define_method "#{field_data}_with_default" do
          self.send("#{field_data}_without_default") || {}
        end
        alias_method_chain field_data, :default
      end

      # return data from foreign registry if any data was synced yet
      define_method "#{field_data}_with_sync" do
        current_data = self.send "#{field_data}_without_sync"
        if current_data.present? then current_data else self.send "#{field}_synced_data" end
      end
      alias_method_chain field_data, :sync

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

      define_method "sync_#{field_data}" do
        value = self.send "#{field}_synced_data"
        self.send "#{field_data}=", value if value.present?
      end

      before_create "fill_#{field_data}"
      define_method "fill_#{field_data}" do
        self.send "sync_#{field_data}" if self.send(field_data).blank?
      end

      before_update "sync_#{field_data}"

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
