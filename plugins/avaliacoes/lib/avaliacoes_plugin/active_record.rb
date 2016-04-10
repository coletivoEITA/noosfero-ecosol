class AvaliacoesPlugin::ActiveRecord < ActiveRecord::Base

  self.abstract_class = true
  self.primary_key = :Chave
  alias_attribute :id, :Chave

  config = YAML::load File.read("#{File.dirname __FILE__}/../../config/database.yml")

  establish_connection config

end
