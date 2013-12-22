class AddImageIdToOauth2Client < ActiveRecord::Migration
  def self.up
    add_column :oauth2_clients, :image_id, :integer
  end

  def self.down
    remove_column :oauth2_clients, :image_id
  end
end
