desc "Creates new enterprises from the csv file - SIES Data"
task :sies_new_enterprises do
  require 'script/lib/fbes_enterprise_call'
  require 'script/lib/sies_new_enterprises'

  if ENV["FILE"].blank?
    puts "sintax:"
    puts "  rake sies_new_enterprises FILE=filename"
    return
  end

  init_log "sies-new-enterprises.log"
  enterprises = load_sheet ENV["FILE"]

  puts "Carregando empreendimentos"
  existing = Enterprise.where(['created_at > ? AND visible = true AND enabled = false', Date.today - 10.days]).order('id ASC')
  sies_enterprise_map = {}; existing.each do |e|
    id_sies = e.data[:id_sies]
    sies_enterprise_map[id_sies] = e
  end

  puts "Iniciando importação..."
  enterprises.each do |data|
    enterprise = sies_enterprise_map[data[:data][:id_sies]]

    if enterprise
      #enterprise.save!
    else
      #enterprise = create_enterprise data
    end
    data[:record] = enterprise
  end

  puts "Exportando CSV com dados importados"
  export_imported enterprises

  puts "Importação concluída!"
end

desc "Put private data"
task :sies_put_private_data do
  require 'script/lib/fbes_enterprise_call'
  require 'script/lib/sies_new_enterprises'

  if ENV["FILE"].blank?
    puts "sintax:"
    puts "  rake sies_put_private_data FILE=filename"
    return
  end

  enterprises = []
  rows = CSV.open ENV["FILE"], 'r'
  rows.shift
  rows.each do |row|
    enterprises << {
      :data => {
        :id_sies => row[0].to_i,
        :private => {
          :contact_phone1 => row[9].to_s,
          :contact_phone2 => row[11].to_s,
          :contact_phone3 => row[13].to_s,
          :contact_phone4 => row[15].to_s,
          :contact_phone5 => row[17].to_s,
        },
      },
    }
  end

  puts "Carregando empreendimentos"
  existing = Enterprise.where(['visible = true']).order('id ASC')
  sies_enterprise_map = {}; existing.each do |e|
    id_sies = e.data[:id_sies]
    sies_enterprise_map[id_sies] = e
  end

  puts "Inserindo telefones..."
  enterprises.each do |data|
    enterprise = sies_enterprise_map[data[:data][:id_sies]]
    next puts "Não pode encontrar empreendimento com ID SIES #{data[:data][:id_sies]}" if enterprise.blank?

    enterprise.data.update data[:data]
    enterprise.save!
  end
end

desc "Export the full list of enterprises"
task :sies_export_all_enterprises do
  require 'script/lib/fbes_enterprise_call'
  require 'script/lib/sies_new_enterprises'

  puts "Carregando empreendimentos"
  enterprises = Enterprise.where(['visible = true']).order('id ASC').map do |enterprise|
    {
      :id_sies => enterprise.data[:id_sies],
      :record => enterprise,
    }
  end

  puts "Exportando CSV com dados importados"
  export_imported enterprises
end

desc "Remove enterprises from the csv file - SIES Data"
task :sies_remove_enterprises do
  require 'script/lib/fbes_enterprise_call'
  require 'script/lib/sies_new_enterprises'

  if ENV["FILE"].blank?
    puts "sintax:"
    puts "  rake sies_remove_enterprises FILE=filename"
    return
  end

  init_log "sies-remove-enterprises.log"

  rows = CSV.open ENV['FILE'], 'r'
  rows.shift
  ids = rows.map{ |row| row[2] }
  enterprises = Enterprise.where(:id => ids)

  #filename = "sies_removed_enterprise_list.csv"
  #CSV.open filename, "w" do |csv|
  #  csv << ['Nome do empreendimento', 'URL do empreendimento no Cirandas', 'ID do SIES', 'UF', 'Cidade']

  #  enterprises.each do |e|
  #    url = "#{$environment.top_url}/#{e.identifier}"
  #    city = e.region
  #    state = e.region.parent
  #    csv << [e.name, url, e.data[:id_sies], state.name, city.name]
  #  end
  #end

  enterprises.find_each do |e|
    next $log.error "Empreendimento #{e.inspect} já foi ativado!" if e.enabled
    e.destroy
  end
end

desc "Update disabled enterprises from the csv file - SIES Data"
task :sies_update_enterprises do
  require 'script/lib/fbes_enterprise_call'
  require 'script/lib/sies_new_enterprises'

  if ENV["FILE"].blank?
    puts "sintax:"
    puts "  rake sies_update_enterprises FILE=filename"
    return
  end

  init_log "sies-update-enterprises.log"

  id_data_map = {}

  rows = CSV.open ENV['FILE'], 'r'
  rows.shift
  rows.each do |row|
    id = row[0].to_i
    id_data_map[id] = {
      :data => {
        :id_sies => row[2].to_i,
        :cnpj => row[3].to_s,
      },
      :zip_code => row[8].to_s.squish,
      :state => row[9].to_s.squish,
      :city => row[10].to_s.squish.titleize,
      :address => "#{row[11].to_s}, #{row[12].to_s}".titleize,
      :contact_email => row[13].to_s.normalize_email,
      :organization_website => row[14].to_s,
      :contact_person => row[15].to_s.squish.titleize,
      :contact_phone => row[16].to_s.squish,
    }
  end

  enterprises = Enterprise.find id_data_map.keys
  enterprises.each do |e|
    data = id_data_map[e.id]

    puts "Atualizando empreendimento '#{e.identifier}'"

    e.data.merge! data.delete(:data)
    e.update_attributes! data

    data[:record] = e
  end

  puts "Exportando CSV com dados importados"
  export_imported id_data_map.values
end
