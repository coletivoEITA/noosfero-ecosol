class AddDeletedAtOnSupportedSoftDeleteModels < ActiveRecord::Migration

  Tables = %w[
    products profiles articles users
  ]
  PluginTables = %w[
    suppliers_plugin_suppliers suppliers_plugin_source_products
  ]

  def change
    Tables.each do |table|
      add_column table, :deleted_at, :datetime
      add_index table, :deleted_at
    end
    PluginTables.each do |table|
      next unless ActiveRecord::Base.connection.table_exists? table
      add_column table, :deleted_at, :datetime
      add_index table, :deleted_at
    end
  end

end
