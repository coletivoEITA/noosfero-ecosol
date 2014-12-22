class RemoveNicknameLimit < ActiveRecord::Migration
  def self.up
    change_column :profiles, :nickname, :string, :limit => 255
  end

  def self.down
    change_column :profiles, :nickname, :string, :limit => 16
  end
end
