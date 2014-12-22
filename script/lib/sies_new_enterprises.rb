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
      :nickname => row[2].to_s,
      :address => extract_row_address(row),
    }
  end

  enterprises
end

def create_enterprise data
  state = data[:state]

  $log.info "#{$log_prefix} Criando empreendimento '%s'..." % data[:name]

  data[:identifier] = generate_enterprise_identifier data[:name], data[:nickname], data[:city]
  $log.info "#{$log_prefix} Usando identificador %s" % identifier

  data[:nickname] = '' if data[:nickname].length > 15

  enterprise = Enterprise.new data
  enterprise.public_profile = true

  enterprise_update_address enterprise, city, state, address, address2, postal_code

  enterprise.save!

  printf "."
  $stdout.flush

  data[:record] = enterprise
  data[:url] = "#{$environment.top_url}/#{enterprise.identifier}"
#  data[:observations] << "Sem gestores associados!" if users.blank?

  enterprise
rescue Exception => e
  puts e.message
  $log.fatal "#{$log_prefix} Não foi possível criar o empreendimento devido a exceção '%s'" % e.message
  $log.fatal e.backtrace.join "\n"

  #data[:url] = "Não foi possível registrar empreendimento"
  #data[:observations] << e.message
#  $enterprises_not_created << data

  nil
end

def update_enterprise data, enterprise
  data[:identifier] = generate_enterprise_identifier data[:name], data[:nickname], data[:city], enterprise
  data[:nickname] = '' if data[:nickname].length > 15
  data[:contact_phone] = ''

  puts "Atualizando empreendimento '%s' com o identificador '%s'" % [enterprise.name, data[:identifier]]

  begin
    enterprise.articles.destroy_all
    enterprise.apply_template $environment.inactive_enterprise_template
    enterprise.update_attributes! data
  rescue => e
    puts "Erro '#{e.message}' ao atualizar #{enterprise.inspect}, usando identificador '#{data[:identifier]}'."
  end

  # remove references to avoid leak
  enterprise.reload
  GC.start
end

def export_imported enterprises
  filename = "sies_new_enterprises-imported-list.csv"
  CSV.open filename, "w" do |csv|
    csv << ['Id sies', 'nome', 'url', 'uf', 'cidade', 'código ativação', 'ano fundação', 'nome para contato', 'indicado pelo forum', 'telefones', 'email']

    enterprises.each do |data|
      enterprise = data[:record]
      next unless enterprise

      activation_task = enterprise.tasks.where(:type => 'EnterpriseActivation').first
      url = "#{$environment.top_url}/#{enterprise.identifier}"

      contact_phone = ([enterprise.data[:contact_phone]] + (enterprise.data[:private] || {}).values).join ', '

      csv << [
        enterprise.data[:id_sies],
        enterprise.name,
        url,
        enterprise.data[:state],
        enterprise.data[:city],
        (activation_task.code rescue ''),
        enterprise.data[:foundation_year],
        enterprise.data[:contact_person],
        if enterprise.enabled and enterprise.created_at.year > 2012 then 'sim' else '' end,
        contact_phone,
        enterprise.data[:contact_email],
      ]
    end
  end

  filename
end


