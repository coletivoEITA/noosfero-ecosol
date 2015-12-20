class ScopeCmsLearningPluginLearningClass < ActiveRecord::Migration
  def self.up
    Article.update_all ["type = 'CmsLearningPlugin::Learning'"], {:type => 'CmsLearningPluginLearning'}
  end

  def self.down
    say "this migration can't be reverted"
  end
end
