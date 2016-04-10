class AddDataToMailing < ActiveRecord::Migration

  def change
    add_column :mailings, :data, :text, default: {}.to_yaml
  end

end
