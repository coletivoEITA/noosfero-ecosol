Peek.into Peek::Views::Git
Peek.into Peek::Views::PerformanceBar

Peek.into Peek::Views::Rblineprof
Peek.into Peek::Views::GC

Peek.into Peek::Views::PG
Peek.into Peek::Views::Dalli

Peek.into Peek::Views::ActiveResource

class PeekProfilingPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('peek_profiling_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('peek_profiling_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    [].map{ |j| "javascripts/#{j}" }
  end

  def body_beginning
    lambda do
      render 'peek/bar'
    end
  end

  def head_ending
    lambda do
      javascript_include_tag 'peek', 'peek/views/rblineprof'
      stylesheet_link_tag 'peek', 'peek/views/rblineprof', 'peek/views/rblineprof/pygments'
    end

  end

end

