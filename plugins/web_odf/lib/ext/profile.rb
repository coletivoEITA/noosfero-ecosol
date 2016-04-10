require_dependency 'profile'

class Profile

  has_many :web_odf_documents, class_name: 'WebODFPlugin::Document'

end
