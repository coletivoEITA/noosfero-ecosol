class ChangeColumnTypeElementQuantityToString2 < ActiveRecord::Migration
  def self.up
    change_column :exchange_plugin_exchange_elements, :quantity, :string
  end

  def self.down
  end
end
