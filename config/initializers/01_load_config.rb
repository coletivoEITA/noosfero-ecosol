file = "#{RAILS_ROOT}/config/noosfero.yml"
NOOSFERO_CONF = File.exists?(file) ? YAML.load_file(file)[RAILS_ENV] || {} : {}

ActiveRecord::Base.connection.instance_variable_set :@logger, Logger.new(STDOUT) if Rails.env.development?
