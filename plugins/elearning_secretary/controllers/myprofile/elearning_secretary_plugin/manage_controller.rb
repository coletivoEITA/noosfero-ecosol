class ElearningSecretaryPlugin::ManageController < MyProfileController

  def index

  end

  def grades_export
    @profiles = environment.people.find params[:student_ids].split(',')
    @file = AvaliacoesPlugin::Report.grades @profiles
    send_file @file, type: 'application/xlsx', disposition: 'attachment', filename: 'test.xlsx'
  end

  protected

  # inherit routes from core skipping use_relative_controller!
  def url_for options
    options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
    super options
  end
  helper_method :url_for

end
