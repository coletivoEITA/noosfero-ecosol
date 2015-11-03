class WebODFPlugin::EditionController < MyProfileController

  def file
    @document = profile.webodf_documents.find params[:id]
    send_data @document.odf, filename: @document.filename
  end

end

