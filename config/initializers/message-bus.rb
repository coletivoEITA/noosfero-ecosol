MessageBus.user_id_lookup do |env|
  env['rack.session']['user']
end
