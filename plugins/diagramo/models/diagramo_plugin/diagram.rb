require 'php_serialize'
require 'mechanize'

class DiagramoPlugin::Diagram < Article

  settings_items :diagramo_id

  before_create :diagramo_create
  after_save :diagramo_save
  after_destroy :diagramo_destroy

  def self.short_description
    "Diagrama"
  end

  def self.description
    "Construa um diagrama com o Diagramo"
  end

  def self.icon_name article = nil
    'diagramo'
  end

  def description
    self.body
  end

  def to_html options = {}
    article = self
    lambda do
      render 'content_viewer/diagramo_plugin/diagram', :article => article
    end
  end

  def author?
    self.user and self.user.id == self.author_id
  end

  def diagramo_uri
    if self.author?
      "#{self.diagramo_editor_url}?diagramId=#{self.diagramo_id}&biscuit=#{diagramo_cookie}"
    else
      "#{self.diagramo_view_diagram_url}?diagramId=#{self.diagramo_id}"
    end
  end

  def user
    @user ||= User.current.person rescue nil
  end

  def diagramo_email
    "#{self.user.identifier}@#{self.environment.default_hostname}"
  end
  def diagramo_password
    Digest::MD5.hexdigest self.user.identifier
  end

  protected

  def admin_email
    self.environment.diagramo_settings.admin_email
  end
  def admin_password
    self.environment.diagramo_settings.admin_password
  end

  def diagramo_url
    self.environment.diagramo_settings.url
  end
  def diagramo_login_url
    "#{self.diagramo_url}/editor/login.php"
  end
  def diagramo_controller_url
    "#{self.diagramo_url}/editor/common/controller.php"
  end
  def diagramo_editor_url
    "#{self.diagramo_url}/editor/editor.php"
  end
  def diagramo_view_diagram_url
    "#{self.diagramo_url}/editor/viewDiagram.php"
  end

  def diagramo_login
    self.mech.post self.diagramo_controller_url, :action => 'loginExe', :email => diagramo_email, :password => diagramo_password
  end
  def diagramo_logout
    self.mech.post self.diagramo_controller_url, :action => 'logoutExe'
  end

  def diagramo_user_exists?
    self.diagramo_logout
    page = self.diagramo_login
    page.uri.to_s != self.diagramo_login_url
  end

  def mech
    @mech ||= Mechanize.new
  end

  def diagramo_create_user
    page = self.mech.post self.diagramo_controller_url, :action => 'loginExe', :email => self.admin_email, :password => self.admin_password
    page = self.mech.post self.diagramo_controller_url, :action => 'addUserExe', :email => diagramo_email, :password => diagramo_password
    # logout admin
    self.diagramo_logout
    self.diagramo_login
  end

  def diagramo_create
    return if self.diagramo_id.present?

    self.diagramo_create_user unless self.diagramo_user_exists?
    page = self.mech.post self.diagramo_controller_url, :action => 'firstSaveExe', :public => 'true', :title => self.title, :description => self.description
    page.uri.to_s =~ /diagramId=(.*)$/
    self.diagramo_id = $1
  end

  def diagramo_save
    return if self.diagramo_id.blank?

    # FIXME: can't save diagram with action save
    #self.diagramo_login
    #self.mech.post self.diagramo_controller_url, :action => 'save', :diagramId => self.diagramo_id, :title => self.title, :description => self.description
  end

  def diagramo_destroy
    self.diagramo_login
    self.mech.post self.diagramo_controller_url, :action => 'deleteDiagramExe', :diagramId => self.diagramo_id
  end

  def diagramo_cookie
    biscuit = PHP.serialize({:email => diagramo_email, :password => Digest::MD5.hexdigest(diagramo_password)})
    biscuit = strict_encode64 biscuit
    biscuit = biscuit.reverse
    biscuit = uuencode biscuit
    biscuit = strict_encode64 biscuit
  end

  # for ruby 1.8
  def strict_encode64 str
    Base64.encode64(str).gsub(/\n/, '')
  end
  def uuencode str
    [str].pack('u') + "`\n"
  end

end
