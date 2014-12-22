require 'rubygems'
require "#{File.dirname(__FILE__)}/../../config/environment"
Noosfero.default_locale = 'pt'
FastGettext.locale = Noosfero.default_locale
I18n.locale = Noosfero.default_locale

require 'unicode'
require 'fastercsv'
CSV = FasterCSV

require 'logger'

FileFormat = /([A-Z]{2,2})-enterprises.csv/

PasswordChars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

CSVHeader = [
  "Nome do Empreendimento (EES)", "Sigla do EES", "Cidade",
  "Nome da primeira pessoa de referência do EES", "E-mail da primeira pessoa de referência do EES", "Telefones da primeira pessoa de referência do EES",
  "Nome da segunda pessoa de referência do EES", "E-mail da segunda pessoa de referência do EES", "Telefones da segunda pessoa de referência do EES",
]

$environment = Environment.default
$files = []
$enterprises = []
$enterprises_not_created = []

class String
  def downcase
    Unicode::downcase(self)
  end
  def normalize_spaces
    self.gsub("\302\240", ' ').squish
  end
  def normalize_ascii
    ActiveSupport::Inflector.transliterate(self).normalize_spaces
  end
  def normalize_slug
    self.normalize_ascii.to_slug.gsub(" ", "")
  end
  def normalize_email
    self.normalize_ascii.gsub(" ", "").downcase.to_s
  end
  def normalize_name
    self.normalize_spaces.downcase.capitalize
  end
  def normalize_zipcode
    self.normalize_ascii
    "#{self[0..4]}-#{self[5..7]}"
  end
end

require_dependency 'user'
class User
  def self.disable_signup_emails
    define_method :deliver_signup_welcome_email, proc{}
    define_method :deliver_activation_code, proc{}
    define_method :delay_activation_check, proc{}
  end
end

def init_log name
  $log_path = "#{File.dirname(__FILE__)}/../../log"
  $log_name = name
  $log = Logger.new "#{$log_path}/#{$log_name}"
  $log.debug "Script iniciou execução em #{Time.now}"
end

def generate_enterprise_identifier name, nickname, city, enterprise = nil
  identifier = nickname.normalize_slug if identifier.blank? and nickname.present?
  identifier = name.normalize_slug if identifier.blank? or Profile::RESERVED_IDENTIFIERS.include? identifier

  if enterprise.blank?
    profile = Profile[identifier]
    if profile.present?
      if profile.community?
        identifier = "ees-" + identifier
      else
        identifier = "#{if nickname.present? then nickname else name end} #{city}".normalize_slug
      end
    end
  end

  i = 1
  orig_identifier = identifier
  while (profile = Profile[identifier]).present? and enterprise != profile
    identifier = "#{orig_identifier}#{i}"
    i += 1
  end

  identifier
end

def unique_login_from_name name, suffix = ""
  login = "#{name.split(' ')[0]}#{name.split(' ')[-1]}"
  login = login.normalize_slug

  i = 1
  while (user = User.find_by_login(login)).present?
    login = "#{login}#{i}"
    i += 1
  end

  login
end

def random_password len = 8
  Array.new(len){ PasswordChars[rand PasswordChars.size] }.join
end

def load_sheet file_path
  enterprises = []
  file_path =~ FileFormat
  state = $1

  rows = CSV.open file_path, 'r'
  rows.shift
  rows.each do |row|
    adm_users = []
    name, email, phone = row[3].to_s.normalize_name, row[4].to_s.normalize_email, row[5].to_s
    adm_users << {:name => name, :mail => email, :phone => phone}
    name, email, phone = row[6].to_s.normalize_name, row[7].to_s.normalize_email, row[8].to_s
    adm_users << {:name => name, :mail => email, :phone => phone}

    name = row[0].to_s.normalize_name
    identifier = row[1].to_s.normalize_slug
    city = row[2].to_s

    enterprises << {:name => name, :identifier => identifier, :city => city, :state => state,
                    :url => nil, :observations => [], :adm_users => adm_users, }
  end

  enterprises
end

def enterprise_update_address enterprise, city, state, address, address2, postal_code
  $log.info "#{$log_prefix} Registrando dados geográficos do empreendimento..."
  if !state.blank? and !city.blank?
    enterprise.city_with_region = city.to_s
    enterprise.state_with_region = State.find_by_acronym(state).name rescue state
    $log.info "#{$log_prefix} registrado!"
  else
    $log.info "#{$log_prefix} falta dados para cidade!"
  end

  enterprise.address = address
  enterprise.address += ", #{address2}" if address2.present?

  enterprise.zip_code = postal_code
end


def find_enterprise name, identifier
  $log.info "Procurando empreendimento '%s'..." % name.normalize_name

  if !identifier.blank?
    identifier = identifier.normalize_slug
  elsif !name.blank?
    identifier = name.normalize_slug
  end

  enterprise = Enterprise[identifier]
  if enterprise.blank?
    identifier = "ees-#{identifier}"
    enterprise = Enterprise[identifier]
    if enterprise.blank?
      $log.info "não encontrado!"
    else
      $log.info "encontrado!"
    end
  else
     $log.info "encontrado!"
  end

  enterprise
end

def parse_opts help=nil
  puts help if ARGV.blank? and help.present?
  ARGV.each do |file|
    raise "Arquivo '#{file}' não tem nome no formato 'SIGLAESTADO-enterprises.csv'" unless file =~ FileFormat
    $files << file
  end
end

def load_enterprises
  $enterprises = []
  $files.each do |file|
    $log.debug "Carregando empreendimentos do arquivo '%s'" % [file]
    $enterprises += load_sheet file
  end
end

def export_imported
  filename = "fbes-enterprise-call-imported-list.csv"
  CSV.open filename, "w" do |csv|
    csv << ['Página', 'Observações', 'Estado',
            "Perfil do primeiro gestor", "Perfil do segundo gestor"] + CSVHeader

    $enterprises.each do |data|
      enterprise = data[:record]

      first_admin_login = data[:adm_users][0][:record].login rescue nil
      second_admin_login = data[:adm_users][1][:record].login rescue nil
      first_admin_url = if first_admin_login.blank? then '' else "#{$environment.top_url}/#{first_admin_login}" end
      second_admin_url = if second_admin_login.blank? then '' else "#{$environment.top_url}/#{second_admin_login}" end

      csv << [
        data[:url], data[:observations], data[:state],
        first_admin_url, second_admin_url,
        data[:name], data[:identifier], data[:city],
        data[:adm_users][0][:name], data[:adm_users][0][:mail], data[:adm_users][0][:phone],
        data[:adm_users][1][:name], data[:adm_users][1][:mail], data[:adm_users][1][:phone],
      ]
    end
  end

  filename
end

