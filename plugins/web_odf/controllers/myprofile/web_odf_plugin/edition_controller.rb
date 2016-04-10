class WebODFPlugin::EditionController < MyProfileController

  def file
    @document = profile.web_odf_documents.where(id: params[:id]).first
    return render text: File.read(WebODFPlugin::EmptyDocument) if @document.blank? or @document.body.blank?
    send_data @document.odf, filename: @document.filename
  end

end

