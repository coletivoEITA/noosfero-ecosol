class CustomFormsPlugin::TextField < CustomFormsPlugin::Field
  set_table_name :custom_forms_plugin_fields

  attr_accessible :name

  validates_inclusion_of :show_as, :in => %w(input textarea tinymce)

  def show_as
    self['show_as'] || 'input'
  end

end
