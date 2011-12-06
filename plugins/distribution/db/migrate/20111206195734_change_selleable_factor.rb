class ChangeSelleableFactor < ActiveRecord::Migration
  def self.up
    change_table :distribution_plugin_products do |t|
      t.rename :selleable_factor, :unit_detail
      t.change :unit_detail, :string
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
