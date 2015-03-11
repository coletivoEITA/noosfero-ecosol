class ChangeDatetimeTimezones < ActiveRecord::Migration

  # disabled by default, set to noosfero 1.0.0 migration date to ENABLE (format: 2014/11/24 00:00:00)
  FromDate = ENV['CHANGE_TIMEZONE_FROM']

  def up
    # from local to utc
    offset = Time.zone.now.formatted_offset.to_i
    apply_offset(-offset)
  end

  def down
    # from utc to local
    offset = Time.zone.now.formatted_offset.to_i
    apply_offset(offset)
  end

  def apply_offset offset
    return unless FromDate.present?
    conn = ActiveRecord::Base.connection

    ActiveRecord::Base.transaction do
      conn.tables.each do |table|
        conn.schema_cache.columns(table).select do |column|
          next unless column.sql_type.in? ['timestamp without time zone']
          query = "UPDATE #{table} SET \"#{column.name}\" = \"#{column.name}\" + INTERVAL '#{offset} hour' WHERE \"#{column.name}\" >= '#{FromDate}'"
          say query
          conn.execute query
        end
      end
    end
  end

end
