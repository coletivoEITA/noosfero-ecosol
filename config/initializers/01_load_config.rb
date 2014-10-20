file = Rails.root.join('config', 'noosfero.yml')
NOOSFERO_CONF = File.exists?(file) ? YAML.load_file(file)[Rails.env] || {} : {}

NOOSFERO_CONF['cache_stylesheets'] = true if NOOSFERO_CONF['cache_stylesheets'].nil?
NOOSFERO_CONF['cache_javascripts'] = true if NOOSFERO_CONF['cache_javascripts'].nil?

