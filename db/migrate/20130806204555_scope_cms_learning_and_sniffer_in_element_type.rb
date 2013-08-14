class ScopeCmsLearningAndSnifferInElementType < ActiveRecord::Migration
  def self.up
    ExchangePlugin::Element.update_all ["object_type = 'CmsLearningPlugin::Learning'"], :object_type => 'CmsLearningPluginLearning'
    ExchangePlugin::Element.update_all ["object_type = 'SnifferPlugin::Opportunity'"], :object_type => 'SnifferPluginOpportunity'
  end

  def self.down
    end
end
