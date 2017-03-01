class ScopeCmsLearningPluginLearningClass < ActiveRecord::Migration
  def self.up
    Article.where(type: 'CmsLearningPluginLearning').update_all type: 'CmsLearningPlugin::Learning'
  end

  def self.down
    say "this migration can't be reverted"
  end
end
