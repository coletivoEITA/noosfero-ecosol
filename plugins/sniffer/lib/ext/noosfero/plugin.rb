require_dependency "noosfero/plugin"

class Noosfero::Plugin

  # -> Add content to the header of the balloon
  def sniffer_balloon_header
    nil
  end

  # -> Add content to the footer of the balloon
  # returns = lambda block that creates html code.
  def sniffer_balloon_footer
    nil
  end

end
