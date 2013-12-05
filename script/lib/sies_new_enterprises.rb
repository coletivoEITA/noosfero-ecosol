def extract_row_address row
  address = ''
  unless row[7].blank?
    address = row[7]
    address += ', Bairro: ' + row[8] unless row[8].blank?
    address += ', CEP: '+ row[4].to_s.normalize_zipcode unless row[4].blank?
  end
  address
end

def load_sheet file_path
  enterprises = []

  rows = CSV.open file_path, 'r'
  rows.shift
  rows.each do |row|
    enterprises << {
      :data => {
        :id_sies => row[0].to_i,
        :foundation_year => row[3].to_s,
        :state => row[5].to_s,
        :city => row[6].to_s,
        :zip_code => row[4].to_s.normalize_zipcode,
        :contact_email => row[9],
        :contact_person => row[11]
      },
      :name => row[1].to_s.normalize_name,
      :nickname => row[2].to_s.normalize_nickname,
      :address => extract_row_address(row),
      :contact_phone => 'tel'
    }
  end

  enterprises
end

def create_enterprise data
  name = data[:name]
  nickname = data[:nickname]
  identifier = data[:identifier]
  city = data[:city]
  state = data[:state]

#  $log.info "#{$log_prefix} Criando empreendimento '%s'..." % name

  identifier = nickname.normalize_slug if identifier.blank? and nickname.present?
  identifier = name.normalize_slug if identifier.blank? and name.present?

  profile = Profile[identifier]
  if profile.present?
    if profile.community?
      identifier = "ees-" + identifier
    else
      identifier = "#{if nickname.present? then nickname else name end} #{city}".normalize_slug
    end
  end
  i = 1
  while (profile = Profile[identifier]).present?
    identifier = "#{identifier}#{i}"
    i += 1
  end
#  $log.info "#{$log_prefix} Usando identificador %s" % identifier

  data[:identifier] = identifier
  enterprise = Enterprise.new data

#  $log.info "#{$log_prefix} Registrando dados geográficos do empreendimento..."
  if !state.blank? and !city.blank?
    enterprise.city_with_region = city.to_s
    enterprise.state_with_region = State.find_by_acronym(state).name rescue state
#    $log.info "#{$log_prefix} registrado!"
  else
#    $log.info "#{$log_prefix} falta dados para cidade!"
  end

  enterprise.save!
  printf "."
  $stdout.flush

  data[:record] = enterprise
  data[:url] = "#{$environment.top_url}/#{enterprise.identifier}"
#  data[:observations] << "Sem gestores associados!" if users.blank?

  enterprise
rescue Exception => e
  puts e.message
#  $log.fatal "#{$log_prefix} Não foi possível criar o empreendimento devido a exceção '%s'" % e.message
#  $log.fatal e.backtrace.join "\n"

  #data[:url] = "Não foi possível registrar empreendimento"
  #data[:observations] << e.message
#  $enterprises_not_created << data

  nil
end

def export_imported enterprises
  filename = "sies_new_enterprises-imported-list.csv"
  CSV.open filename, "w" do |csv|
    csv << ['Id sies', 'nome', 'url', 'uf', 'cidade', 'código ativação', 'ano fundação', 'nome para contato', 'telefone', 'email']

    enterprises.each do |data|
      enterprise = data[:record]

      url = "#{$environment.top_url}/#{enterprise.identifier}"

      csv << [
        enterprise.data[:id_sies],
        enterprise.name,
        url,
        enterprise.data[:state],
        enterprise.data[:city],
        enterprise.tasks.where(:type => 'EnterpriseActivation').first.code,
        enterprise.data[:foundation_year],
        enterprise.data[:contact_person],
        enterprise.contact_phone,
        enterprise.data[:contact_email]
      ]
    end
  end

  filename
end


