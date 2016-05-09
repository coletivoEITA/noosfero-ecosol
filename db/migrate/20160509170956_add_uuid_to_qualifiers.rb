class AddUuidToQualifiers < ActiveRecord::Migration
  def change
    add_column :qualifiers, :uuid, :string
  end
end
