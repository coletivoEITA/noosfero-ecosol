class ScopeCmsLearningAndSnifferInElementType < ActiveRecord::Migration
  def self.up
    ExchangePlugin::ExchangeElement.update_all ["element_type = 'CmsLearningPlugin::Learning'"], :element_type => 'CmsLearningPluginLearning'
    ExchangePlugin::ExchangeElement.update_all ["element_type = 'SnifferPlugin::Opportunity'"], :element_type => 'SnifferPluginOpportunity'
  end

  def self.down
    end
end
