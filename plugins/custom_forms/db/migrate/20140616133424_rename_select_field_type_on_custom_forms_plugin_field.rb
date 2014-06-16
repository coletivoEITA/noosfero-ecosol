class RenameSelectFieldTypeOnCustomFormsPluginField < ActiveRecord::Migration
  def self.up
    rename_column :custom_forms_plugin_fields, :select_field_type, :show_as
    # remove default as it is now not only for SelectField.
    change_column :custom_forms_plugin_fields, :show_as, :string, :null => true, :default => nil
    update "UPDATE custom_forms_plugin_fields SET show_as='input' WHERE type = 'CustomFormsPlugin::TextField'"
  end
end
