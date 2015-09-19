Slim::PrettyTemplate = Temple::Templates::Tilt Slim::Engine, register_as: :slim, pretty: true
Rails.application.assets.register_engine '.slim', Slim::PrettyTemplate

