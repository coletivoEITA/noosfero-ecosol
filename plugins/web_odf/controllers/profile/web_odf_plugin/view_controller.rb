class WebODFPlugin::ViewController < ContentViewerController

  def file
    @document = profile.webodf_documents.where(id: params[:id]).first
    return render text: File.read(WebODFPlugin::EmptyDocument) if @document.blank? or @document.body.blank?

    send_data @document.odf, filename: @document.filename
  end

  def report
    @document = profile.webodf_documents.find params[:id]
    send_data WebODFPlugin::Export.report(@document.odf, params[:fields]), filename: @document.filename
  end

  def pdf
    @document = profile.webodf_documents.find params[:id]
    send_data WebODFPlugin::Export.pdf(@document.odf), filename: "#{@document.name}.pdf"
  end

  def pdf_report
    @document = profile.webodf_documents.find params[:id]
    send_data WebODFPlugin::Export.pdf_report(@document.odf, params[:fields]), filename: "#{@document.name}.pdf"
  end

end
