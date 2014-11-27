class Theme

  class << self
    def system_themes
      Dir.glob(File.join(Rails.root, 'public', self.system_themes_dir, '*')).map do |path|
        self.new File.basename(path), :base_dir => self.system_themes_dir
      end
    end

    def user_themes_dir
      @user_themes_dir ||= File.join 'user_themes'
    end

    def system_themes_dir
      @system_themes_dir ||= File.join 'designs', 'themes'
    end

    def create(id, attributes = {})
      if find(id) || system_themes.map(&:id).include?(id)
        raise DuplicatedIdentifier
      end
      theme = self.new id, attributes
      theme.save
      theme
    end

    def find id
      if File.directory? File.join(Rails.root, 'public', self.system_themes_dir, id)
        self.new id, :base_dir => self.system_themes_dir
      elsif File.directory? File.join(Rails.root, 'public', self.user_themes_dir, id)
        self.new id
      else
        nil
      end
    end

    def find_by_owner(owner)
      Dir.glob(File.join(Rails.root, 'public', self.user_themes_dir, '*', 'theme.yml')).select do |desc|
        config = YAML.load_file(desc)
        (config['owner_type'] == owner.class.base_class.name) && (config['owner_id'] == owner.id)
      end.map do |desc|
        Theme.find(File.basename(File.dirname(desc)))
      end
    end

    def approved_themes(owner)
      Dir.glob(File.join(Rails.root, 'public', self.system_themes_dir, '*')).map do |item|
        next unless File.exists? File.join(item, 'theme.yml')

        item = "#{File.dirname item}/#{File.readlink(item).gsub(/\/$/, '')}" while File.symlink? item
        id = File.basename item

        config = YAML.load_file File.join(item, 'theme.yml')

        approved = config['public']
        unless approved
          begin
            approved = owner.kind_of?(config['owner_type'].constantize)
          rescue
          end
          approved &&= config['owner_id'] == owner.id if config['owner_id'].present?
        end

        [id, config] if approved
      end.compact.map do |id, config|
        self.new id, config
      end
    end
  end

  class DuplicatedIdentifier < Exception; end

  attr_reader :id
  attr_reader :config
  attr_reader :base_dir
  attr_reader :base_path
  attr_reader :dir
  attr_reader :path

  attr_accessor :style

  def initialize id, attributes = {}
    @id = id
    @base_dir = attributes.delete(:base_dir) || self.class.user_themes_dir
    @base_path = File.join Rails.root, 'public', base_dir
    @dir = File.join @base_dir, @id
    @path = File.join @base_path, @id

    load_config
    attributes.each do |k,v|
      self.send("#{k}=", v) if self.respond_to?("#{k}=")
    end
    config['id'] = id
  end

  def user?
    self.base_dir == self.class.user_themes_dir
  end

  def system?
    self.base_dir == self.class.system_themes_dir
  end

  def private?
    self.config['owner_id'].present?
  end

  def name
    config['name'] || id
  end

  def name=(value)
    config['name'] = value
  end

  def public
    config['public'] || false
  end

  def public=(value)
    config['public'] = value
  end

  StylesheetFiles = [
    'stylesheets/style.scss', 'stylesheets/style.sass',
    'stylesheets/theme.scss', 'stylesheets/theme.sass',
    'style.css',
  ]
  UserStylesheetFiles = %w[ common help menu article button search blocks forms login-box ]

  def stylesheet_file
    return @stylesheet_file if @stylesheet_file.present?
    StylesheetFiles.each do |file|
      return @stylesheet_file = file if File.file? "#{self.path}/#{file}"
    end
    @stylesheet_file
  end

  def style
    @style ||= File.read "#{self.path}/#{self.stylesheet_file}"
  end

  def ==(other)
    other.is_a?(self.class) && (other.id == self.id)
  end

  def private_copy profile
    return self if self.private?

    copy_id = "#{self.id}-profile-#{profile.id}-copy"
    copy_theme = self.class.find(copy_id)
    return copy_theme if copy_theme

    copy_path = "#{self.base_path}/#{copy_id}"
    if system "rm -fr #{copy_path} && cp -fr #{self.path}/ #{copy_path}"
      copy_theme = self.class.new copy_id, :owner => profile, :name => _("Customized %{name}") % { :name => self.name }, :base_dir => self.base_dir
      copy_theme.save
      copy_theme
    end
  end

  def add_css(filename)
    FileUtils.mkdir_p(stylesheets_directory)
    FileUtils.touch(stylesheet_path(filename))
  end

  def update_css(filename, content)
    add_css(filename)
    File.open(stylesheet_path(filename), 'w') do |f|
      f.write(content)
    end
  end

  def read_css(filename)
    File.read(stylesheet_path(filename))
  end

  def css_files
    Dir.glob(File.join(stylesheets_directory, '*.css')).map { |f| File.basename(f) }
  end

  def add_image(filename, data)
    FileUtils.mkdir_p(images_directory)
    File.open(image_path(filename), 'wb') do |f|
      f.write(data)
    end
  end

  def image_files
    Dir.glob(image_path('*')).map {|item| File.basename(item)}
  end

  def stylesheet_path(filename)
    suffix = ''
    unless filename =~ /\.css$/
      suffix = '.css'
    end
    File.join(stylesheets_directory, filename + suffix)
  end

  def stylesheets_directory
    File.join(self.base_path, self.id, 'stylesheets')
  end

  def image_path(filename)
    File.join(images_directory, filename)
  end

  def images_directory
    File.join(self.base_path, id, 'images')
  end

  def save
    FileUtils.mkdir_p File.join(self.base_path, id)

    UserStylesheetFiles.each do |item|
      add_css(item)
    end if self.user?
    File.open("#{self.path}/#{self.stylesheet_file}", "w"){ |f| f << @style } if @style
    self.sass_update

    write_config
    self
  end

  def owner
    return nil unless config['owner_type'] && config['owner_id']
    @owner ||= config['owner_type'].constantize.find(config['owner_id'])
  end

  def owner=(model)
    config['owner_type'] = model.class.base_class.name
    config['owner_id'] = model.id
    @owner = model
  end

  def owner_type
    config['owner_type']
  end
  def owner_type= owner_type
    config['owner_type'] = owner_type
  end

  protected

  def write_config
    File.open(File.join(self.base_path, self.id, 'theme.yml'), 'w') do |f|
      f.write(config.to_yaml)
    end
  end

  def load_config
    file = File.join self.base_path, self.id, 'theme.yml'
    @config = YAML.load_file file rescue {}
    @config ||= {}
  end

  def sass_update
    return unless defined? Sass
    Sass::Plugin.add_template_location "#{self.path}/stylesheets", "#{self.path}/stylesheets"
    Sass::Plugin.update_stylesheets
  end

end
