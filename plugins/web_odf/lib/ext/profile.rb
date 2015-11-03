require_dependency 'profile'

class Profile

  has_many :webodf_documents, class_name: 'WebODFPlugin::Document'

end
