require 'yaml'

RailsRoot = Dir.getwd
ConfigPath = "#{RailsRoot}/config"
LogPath = "#{RailsRoot}/log"
PidDir = 'tmp/pids'
PidPath = "#{RailsRoot}/#{PidDir}"
God.pid_file_directory = PidPath

God::Contacts::Email.defaults do |d|
  d.from_email = "god@#{`hostname`}"
  d.delivery_method = :sendmail
end
God.contact(:email) do |c|
  c.name = 'braulio'
  c.to_email = 'braulio@eita.org.br'
  c.group = 'developers'
end

def env
  ENV['RAILS_ENV'] || 'development'
end

def commons w
  w.dir = RailsRoot
  w.env = {
    'RAILS_ROOT' => RailsRoot,
    'RAILS_ENV' => env,
  }
  w.log = "#{LogPath}/god-#{w.name}.#{env}.log"

  if RailsRoot =~ /\/home\/([^\/]+)\/.+$/
    w.uid = w.gid = $1
  else
    w.uid = w.gid = 'noosfero'
  end

  w.interval = 60.seconds
  w.behavior :clean_pid_file
  w.start_grace = 30.seconds
  w.stop_grace = 30.seconds

  w.transition(:up, :start) do |on|
    on.condition(:process_exits) do |c|
      c.notify = 'developers'
    end
  end

  w.keepalive
end

# based on https://github.com/macournoyer/thin/blob/master/example/thin.god
def monitor_thin
  file = "#{ConfigPath}/thin.yml"
  config = YAML.load_file file
  num_servers = config["servers"] || 1

  (0...num_servers).each do |i|
    port = config['port'] + i

    God.watch do |w|
      w.group = 'thin'
      w.name = "#{w.group}-#{port}"
      commons w

      pid_path = "#{config['chdir'] || RailsRoot}/#{config['pid'] || "#{PidDir}/thin.pid"}"
      ext = File.extname(pid_path)
      w.pid_file = pid_path.gsub(/#{ext}$/, ".#{port}#{ext}")

      w.uid = config['user'] if config['user']
      w.gid = config['group'] if config['group']

      %w[start stop restart].each do |command|
        w.send "#{command}=", "#{w.group} #{command} -C #{file} -o #{port}"
      end

      w.stop_grace = (timeout * (w.stop_grace+3)).seconds if timeout = config['timeout'] and timeout > 0
    end
  end
end

def monitor_solr
  file = "#{RailsRoot}/plugins/solr/config/solr.yml"
  return puts "Solr config file doesn't exist. Ignoring solr." unless File.exists? file
  config = YAML.load_file file

  God.watch do |w|
    w.name = 'solr'
    commons w
    w.pid_file = "#{PidPath}/#{w.name}.#{env}.pid"

    %w[start stop restart].each do |command|
      w.send "#{command}=", "rake solr:#{command}"
    end
  end
end

def monitor_feed_updater
  God.watch do |w|
    w.name = 'feed-updater'
    commons w
    w.pid_file = "#{PidPath}/#{w.name}.#{env}.pid"

    %w[start stop].each do |command|
      w.send "#{command}=", "script/#{w.name} -i #{env} #{command}"
    end
  end
end

def monitor_delayed_job
  God.watch do |w|
    w.name = 'delayed_job'
    commons w
    w.pid_file = "#{PidPath}/#{w.name}.#{env}.pid"

    %w[start stop].each do |command|
      w.send "#{command}=", "script/#{w.name} -i #{env} #{command}"
    end
  end
end

monitor_thin
monitor_solr
monitor_feed_updater
monitor_delayed_job

