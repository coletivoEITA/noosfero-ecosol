class ScopeCmsLearningAndSnifferInElementType < ActiveRecord::Migration
  def self.up
    return unless ActiveRecord::Base.connection.table_exists? "exchange_plugin_elements"
    ExchangePlugin::Element.update_all ["object_type = 'CmsLearningPlugin::Learning'"], :object_type => 'CmsLearningPluginLearning'
    ExchangePlugin::Element.update_all ["object_type = 'SnifferPlugin::Opportunity'"], :object_type => 'SnifferPluginOpportunity'
  end

  def self.down
    end
end
