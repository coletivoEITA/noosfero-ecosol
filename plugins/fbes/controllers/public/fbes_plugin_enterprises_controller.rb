require 'fastercsv'

class FbesPluginEnterprisesController < PublicController

  def search
    if id_sies = params[:id_sies]
      @enterprises = environment.enterprises.where 'data LIKE ?', "%id_sies: #{id_sies}%"
    elsif name = params[:name]
      @enterprises = environment.enterprises.where 'LOWER(name) LIKE ?', "%#{name.downcase}%"
    elsif foundation_year = params[:foundation_year]
      @enterprises = environment.enterprises.where 'data LIKE ?', "%foundation_year: #{foundation_year}%"
    elsif activation_code = params[:activation_code]
      task = Task.find_by_code activation_code
      @enterprises = [task.enterprise] rescue []
    elsif contact_person = params[:contact_person]
      @enterprises = environment.enterprises.where 'data LIKE ?', "%contact_person: %#{contact_person.downcase}%"
    elsif contact_email = params[:contact_email]
      @enterprises = environment.enterprises.where 'data LIKE ?', "%contact_email: %#{contact_email.downcase}%"
    end

    respond_to do |format|
      format.csv do
        csv = FasterCSV.generate do |csv|
          @enterprises.map do |enterprise|
            csv << [
              enterprise.name, url_for(enterprise.url),
              (enterprise.activation_task.code rescue ''), enterprise.foundation_year,
              enterprise.contact_person, enterprise.contact_email
            ]
          end
        end
        render :text => csv
      end
    end
  end

end
