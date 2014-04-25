class AddArticleAndProfileCategorizationCategorizationToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :visible_for_articles, :boolean, :default => true
    add_column :categories, :visible_for_profiles, :boolean, :default => true
    add_column :categories, :choosable, :boolean, :default => true
    Category.update_all ['visible_for_articles = ?', true]
    Category.update_all ['visible_for_profiles = ?', true]
    Category.update_all ['choosable = ?', true]
  end

  def self.down
    say "this migration can't be reverted"
  end
end
