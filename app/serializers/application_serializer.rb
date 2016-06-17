class ApplicationSerializer < ActiveModel::Serializer

  def to_json options = {}
    options.merge! include: '**'
    ActiveModelSerializers::Adapter.create(self, options).to_json
  end

end
