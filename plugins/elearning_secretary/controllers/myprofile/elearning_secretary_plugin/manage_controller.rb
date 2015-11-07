class ElearningSecretaryPlugin::ManageController < MyProfileController

  def index

  end

  def grades_export
    @profiles = environment.people.find params[:student_ids].split(',')
    @file = AvaliacoesPlugin::Report.grades @profiles
    send_file @file, type: 'application/xlsx', disposition: 'attachment', filename: 'test.xlsx'
  end

  def document
    @document = profile.web_odf_documents.find params.fetch(:id)
    @student = environment.people.find params.fetch(:student_id)
    @attributes = @student.attributes.except('data').merge @student.attributes['data']
    @type = params.fetch :type
    @method = WebODFPlugin::Export.method "#{@type}_report"
    send_data @method.call(@document.odf, @attributes), filename: "#{@document.name}.#{@type}"
  end

  protected

  # inherit routes from core skipping use_relative_controller!
  def url_for options
    options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
    super options
  end
  helper_method :url_for

end
