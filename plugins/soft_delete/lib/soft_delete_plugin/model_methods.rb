module SoftDeletePlugin::ModelMethods

  def soft_delete_associations_with_deleted *associations
    associations.each do |association|
      association = association.to_s
      reflection = self.reflections[association]
      raise "Can't find reflection for '#{association}'" unless reflection

      scope = reflection.instance_variable_get :@scope
      new_scope = if scope then -> { scope.call.with_deleted } else -> { with_deleted } end
      send reflection.macro, reflection.name, new_scope, reflection.options
    end

  end

end

ActiveRecord::Base.extend SoftDeletePlugin::ModelMethods

