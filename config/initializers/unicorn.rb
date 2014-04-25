if defined? Unicorn and Rails.env.production?
  middleware = ActionController::Dispatcher.middleware

  require 'unicorn/worker_killer'
  # Max requests per worker
  #max_request_min = 500
  #max_request_max = 600
  #use Unicorn::WorkerKiller::MaxRequests, max_request_min, max_request_max
  # Max memory size (RSS) per worker
  oom_min = 192 * (1024**2)
  oom_max = 256 * (1024**2)
  middleware.use Unicorn::WorkerKiller::Oom, oom_min, oom_max

  GC_FREQUENCY = 20
  require_dependency 'unicorn/oob_gc'
  GC.disable # Don't run GC during requests
  use Unicorn::OobGC, GC_FREQUENCY # Only GC once every GC_FREQUENCY requests
end
