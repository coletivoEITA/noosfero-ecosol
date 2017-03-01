class WebODFPlugin::Export

  def self.odt_report odt, params
    tempfile odt do |f|
      report = ODFReport::Report.new f.path do |r|
        params.each do |field, value|
          r.add_field field, value
        end
      end
      report.generate
    end
  end

  def self.pdf odt
    tempfile odt do |f|
      Dir.chdir File.dirname(f.path) do
        system "loffice --headless --convert-to pdf #{f.path}"
        pdf = "#{File.basename f.path, '.*'}.pdf"
        data = File.read pdf
        File.unlink pdf
        data
      end
    end
  end

  def self.pdf_report odt, params
    self.pdf self.odt_report(odt, params)
  end

  private

  def self.tempfile data
    Tempfile.create 'odf-report' do |f|
      f.sync = true; f.binmode
      f.write data
      yield f
    end
  end

end

