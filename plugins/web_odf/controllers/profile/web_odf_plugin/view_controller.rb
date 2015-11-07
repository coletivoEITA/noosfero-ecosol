class WebODFPlugin::ViewController < ContentViewerController

  def file
    @document = profile.web_odf_documents.find params[:id]
    send_data @document.odf, filename: @document.filename
  end

  def report
    @document = profile.web_odf_documents.find params[:id]
    send_data WebODFPlugin::Export.odt_report(@document.odf, params[:fields]), filename: @document.filename
  end

  def pdf
    @document = profile.web_odf_documents.find params[:id]
    send_data WebODFPlugin::Export.pdf(@document.odf), filename: "#{@document.name}.pdf"
  end

  def pdf_report
    @document = profile.web_odf_documents.find params[:id]
    send_data WebODFPlugin::Export.pdf_report(@document.odf, params[:fields]), filename: "#{@document.name}.pdf"
  end

end
