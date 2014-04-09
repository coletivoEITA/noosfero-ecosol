file = "#{RAILS_ROOT}/config/noosfero.yml"
NOOSFERO_CONF = File.exists?(file) ? YAML.load_file(file)[RAILS_ENV] || {} : {}

NOOSFERO_CONF['cache_stylesheets'] = true if NOOSFERO_CONF['cache_stylesheets'].blank?
NOOSFERO_CONF['cache_javascripts'] = true if NOOSFERO_CONF['cache_javascripts'].blank?

