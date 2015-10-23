class AvaliacoesPlugin::GradesController < MyProfileController

  def index
    @student = environment.people.find params[:student_id]
  end

end
