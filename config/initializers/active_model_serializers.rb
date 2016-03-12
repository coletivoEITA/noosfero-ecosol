ActiveModel::Serializer.config.adapter = ActiveModelSerializers::Adapter::Json

class ActiveModel::Serializer

  def serializable_hash
    ActiveModel::SerializableResource.new(self.object, serializer: self.class, include: '**').serializable_hash
  end

  alias_method :to_hash, :serializable_hash

end
