class CreateArticleResources < ActiveRecord::Migration
  def self.up
    create_table :article_resources do |t|
      t.integer :article_id
      t.integer :resource_id
      t.string :resource_type

      t.timestamps
    end
    add_index :article_resources, :article_id
    add_index :article_resources, :resource_id
    add_index :article_resources, :resource_type
  end

  def self.down
    drop_table :article_resources
  end
end
