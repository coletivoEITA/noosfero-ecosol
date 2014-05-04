RailsRoot = File.expand_path "#{File.dirname __FILE__}/.."
PidsDir = "#{RailsRoot}/tmp/pids"

ListenAddress = "127.0.0.1"
ListenPort = 50000
UnixListen = "tmp/unicorn.sock"
Backlog = 2048

Workers = 10
Timeout = 30

WorkerWarmUp = true
WorkerWarmUpTime = 4
WorkerWarmUpUrl = '/'

WorkerKillByRequests = 500..600
WorkerKillByMemory = 144..192

# FIXME: this makes the worker too big and activate Unicorn::WorkerKiller::Oom
WorkerOutOfBandGcFrequency = nil

WorkerListen = true
WorkerPidFile = true


working_directory RailsRoot

worker_processes Workers
timeout Timeout

#stderr_path "#{RailsRoot}/log/unicorn.stderr.log"
#stdout_path "#{RailsRoot}/log/unicorn.stdout.log"
pid "#{PidsDir}/unicorn.pid"

listen "#{RailsRoot}/#{UnixListen}", :backlog => Backlog
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
    old_pid_file = "#{PidsDir}/unicorn.pid.oldbin"
    if File.exists? old_pid_file
      old_pid = File.read(old_pid_file).to_i

      Workers.times.each do |worker_nr|
        sleep WorkerWarmUpTime
        Process.kill "TTOU", old_pid
      end if WorkerWarmUp

      begin
        Process.kill "QUIT", old_pid
        File.delete old_pid_file
      rescue Errno::ENOENT, Errno::ESRCH
        # someone else did our job for us
      end
    end
  end if worker.nr == 0 # only execute once
end

after_fork do |server, worker|
  # Start up the database connection again in the worker
  ActiveRecord::Base.establish_connection if defined? ActiveRecord::Base

  # reset memcache connection
  Rails.cache.instance_variable_get(:@data).reset if Rails.cache.class == ActiveSupport::Cache::MemCacheStore

  middleware = ActionController::Dispatcher.middleware

  if (require 'unicorn/worker_killer' rescue nil)
    middleware.use Unicorn::WorkerKiller::MaxRequests, WorkerKillByRequests.begin, WorkerKillByRequests.end if WorkerKillByRequests
    middleware.use Unicorn::WorkerKiller::Oom, WorkerKillByMemory.begin * (1024**2), WorkerKillByMemory.end * (1024**2) if WorkerKillByMemory
  end

  if WorkerOutOfBandGcFrequency
    require_dependency 'unicorn/oob_gc'
    GC.disable
    middleware.use Unicorn::OobGC, WorkerOutOfBandGcFrequency
  end

  # say to the kernel to kill very big workers first than other processes
  File.open("/proc/#{Process.pid}/oom_adj", "w"){ |f| f << '12' }

  if WorkerWarmUp
    # Don't warm up all workers at once, to allow old workers to use CPU.
    # Also, worker is only considered ready on after_fork complete, so the new worker worker is ready only after warm up.
    sleep worker.nr * WorkerWarmUpTime

    # make a request warming up this new worker
    require 'rack/test'
    request = Rack::MockRequest.new server.app
    request.get "http://#{ListenAddress}:#{ListenPort}#{WorkerWarmUpUrl}"
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

