ActiveModel::Serializer.config.adapter = :attributes

class ActiveModel::Serializer

  def serializable_hash
    ActiveModel::SerializableResource.new(self.object, serializer: self.class).serializable_hash
  end

end
