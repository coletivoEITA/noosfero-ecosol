ActiveModel::Serializer.config.adapter = ActiveModelSerializers::Adapter::Attributes

class ActiveModel::Serializer

  def serializable_hash
    serializable = ActiveModelSerializers::SerializableResource.new self.object, serializer: self.class, include: '**'
    serializable.as_json
  end

  alias_method :to_hash, :serializable_hash

end
