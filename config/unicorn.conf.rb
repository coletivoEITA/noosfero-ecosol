RailsRoot = File.expand_path "#{File.dirname __FILE__}/.."
PidsDir = "#{RailsRoot}/tmp/pids"
ListenAddress = "127.0.0.1"
ListenPort = 50000
Workers = 10
Timeout = 30
Backlog = 2048

WarmUpUrl = '/'

KillByRequests = 500..600
KillByMemory = 160..256
GcFrequency = 20

WorkerListen = true
WorkerPidFile = true


working_directory RailsRoot

worker_processes Workers
timeout Timeout

#stderr_path "#{RailsRoot}/log/unicorn.stderr.log"
#stdout_path "#{RailsRoot}/log/unicorn.stdout.log"
pid "#{PidsDir}/unicorn.pid"

listen "#{RailsRoot}/tmp/unicorn.sock", :backlog => Backlog
listen "#{ListenAddress}:#{ListenPort}", :tcp_nopush => true

# combine Ruby 2 or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.copy_on_write_friendly = true if GC.respond_to? :copy_on_write_friendly=

before_fork do |server, worker|
  # Disconnect since the database connection will not carry over
  ActiveRecord::Base.connection.disconnect! if defined? ActiveRecord::Base

  # a .oldbin file exists if unicorn was gracefully restarted with a USR2 signal
  # we should terminate the old process now that we're up and running
  Thread.new do
    sleep Timeout*2
    old_pid = "#{PidsDir}/unicorn.pid.oldbin"
    if File.exists? old_pid
      begin
        Process.kill "QUIT", File.read(old_pid).to_i
        File.delete old_pid
      rescue Errno::ENOENT, Errno::ESRCH
        # someone else did our job for us
      end
    end
  end
end

after_fork do |server, worker|
  # Start up the database connection again in the worker
  ActiveRecord::Base.establish_connection if defined? ActiveRecord::Base

  # reset memcache connection
  Rails.cache.instance_variable_get(:@data).reset if Rails.cache.class == ActiveSupport::Cache::MemCacheStore

  middleware = ActionController::Dispatcher.middleware

  require 'unicorn/worker_killer'
  # Max requests per worker
  max_request_min = KillByRequests.begin
  max_request_max = KillByRequests.end
  middleware.use Unicorn::WorkerKiller::MaxRequests, max_request_min, max_request_max
  # Max memory size (RSS) per worker
  oom_min = KillByMemory.begin * (1024**2)
  oom_max = KillByMemory.end * (1024**2)
  middleware.use Unicorn::WorkerKiller::Oom, oom_min, oom_max

  # say to the kernel to kill very big workers first than other processes
  File.open("/proc/#{Process.pid}/oom_adj", "w"){ |f| f << '12' }

  require_dependency 'unicorn/oob_gc'
  # Don't run GC during requests
  # FIXME: this makes the worker too big and activate Unicorn::WorkerKiller::Oom
  #GC.disable
  middleware.use Unicorn::OobGC, GcFrequency

  if WarmUpUrl
    # make a request warming up this new worker
    Thread.new do
      require 'rack/test'
      request = Rack::MockRequest.new server.app
      request.get "http://#{ListenAddress}:#{ListenPort}#{WarmUpUrl}"
    end
  end

  if WorkerListen
    # per-process listener ports for debugging/admin/migrations
    server.listen "#{ListenAddress}:#{ListenPort + worker.nr}", :tries => -1, :delay => 5
  end

  if WorkerPidFile
    child_pid_file = server.config[:pid].sub '.pid', ".#{worker.nr}.pid"
    system "echo #{Process.pid} > #{child_pid_file}"
  end
end

