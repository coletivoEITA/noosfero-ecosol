MessageBus.user_id_lookup do |env|
  env['rack.session']['user']
end

MessageBus.long_polling_interval = 30 * 1000
MessageBus.max_active_clients = 10_000

