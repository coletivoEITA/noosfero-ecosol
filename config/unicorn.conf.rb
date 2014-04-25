
rails_root = File.expand_path "#{File.dirname __FILE__}/.."
pids_dir = "#{rails_root}/tmp/pids"
port = 50000

working_directory rails_root

worker_processes 1
timeout 30

stderr_path "#{rails_root}/log/unicorn.stderr.log"
stdout_path "#{rails_root}/log/unicorn.stdout.log"
pid "#{pids_dir}/unicorn.pid"

listen "#{rails_root}/tmp/unicorn.sock", :backlog => 64
listen port, :tcp_nopush => true

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
    sleep 10
    old_pid = "#{pids_dir}/unicorn.pid.oldbin"
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

  # make a request trying to warm up this new worker (something like PassengerPreStart)
  Thread.new do
    Net::HTTP.get URI.parse("http://0.0.0.0:#{port}")
  end
end
