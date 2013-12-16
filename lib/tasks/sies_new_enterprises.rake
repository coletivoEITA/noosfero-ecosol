desc "Creates new enterprises from the csv file - SIES Data"
task :sies_new_enterprises do
  require 'script/lib/fbes_enterprise_call'
  require 'script/lib/sies_new_enterprises'

  unless ENV["FILE"]
    puts "sintaxe:  "
    puts "  rake sies_new_enterprises FILE=filename"

  else
    init_log "sies-new-enterprises.log"
    enterprises = load_sheet ENV["FILE"]

    puts "Iniciando importação..."
    enterprises.each do |data|
      record = create_enterprise data
      #record = Enterprise.where(:name => data[:name]).first
      data[:record] = record
    end

    export_imported enterprises

    puts "Importação concluída!!"
  end

end
