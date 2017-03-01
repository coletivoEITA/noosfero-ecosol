class ApplicationSerializer < ActiveModel::Serializer

  def to_json options = {}
    to_hash(options).to_json
  end

  def to_hash options = {}
    options.merge! include: '**'
    ActiveModelSerializers::Adapter.create(self, options).serializable_hash
  end

end
