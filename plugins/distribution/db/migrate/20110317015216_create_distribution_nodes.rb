class CreateDistributionNodes < ActiveRecord::Migration
  def self.up
    create_table :distribution_nodes do |t|
      t.integer :profile_id

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_nodes
  end
end
