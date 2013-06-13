class CreateCurrencyEnterprises < ActiveRecord::Migration
  def self.up
    create_table :currency_plugin_currency_enterprises do |t|
      t.integer :currency_id
      t.integer :enterprise_id
      t.boolean :is_organizer, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :currency_plugin_currency_enterprises
  end
end
