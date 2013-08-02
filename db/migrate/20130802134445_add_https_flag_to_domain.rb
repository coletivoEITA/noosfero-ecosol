class AddHttpsFlagToDomain < ActiveRecord::Migration
  def self.up
    add_column :domains, :ssl, :boolean
  end

  def self.down
    remove_column :domains, :ssl
  end
end
