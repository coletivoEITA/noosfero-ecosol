require 'rubygems'
require 'faster_csv'
CSV = FasterCSV

#DistributionPlugin::Import.terramater_db Profile['rede-guandu-producao-e-consumo-responsavel'].node,
#  'fornecedor.csv', 'produto.csv', 'fornecedor_produto.csv', 'usuario.csv'

class DistributionPlugin::Import

  def self.terramater_db(node, supplier_csv, products_csv, supplier_products_csv, users_csv, verbose=true)
    environment = node.profile.environment

    node.suppliers.each{ |s| s.destroy! }

    CSV.readlines(users_csv,:headers=> true).each do |row|
      name = row[1].strip
      pass = row[2].strip
      email = row[3].strip

      u = User.find_by_email email
      if u
        puts "registered user: "+email + " " + name if verbose
      else
        puts email if verbose

        login = email.split('@').first.downcase
        login.gsub! '_', ''
        l = login
        i=1
        while (u = User.find_by_login login)
          login = "#{l}_#{i}"
          i+=1
        end

        address = "#{row[7]} - #{row[8]}"
        profile_data = {:name => name, :zip_code => row[4], :city => row[5], :contact_phone => row[6], :address => address}

        p = proc{ puts 'ia mandar email mas nao vou mais' }
        User.send :define_method, :activate, &p
        User.send :define_method, :deliver_activation_code, &p
        User.send :define_method, :delay_activation_check, &p
        u = User.new(:login => login, :email => email, :password => pass, :password_confirmation => pass, :terms_accepted => "1")
        u.terms_of_use = environment.terms_of_use
        u.environment = environment
        u.person_data = profile_data
        u.activated_at = Time.now.utc
        u.activation_code = nil
        u.signup!
        p = u.person
        p.visible = true
        p.save!
        owner_role = Role.find_by_name('owner')
        u.person.affiliate(u.person, [owner_role]) if owner_role
      end

      consumer = DistributionPluginNode.find_or_create u.person
      node.profile.add_member u.person
      node.add_consumer consumer
    end

    id_s = {}
    CSV.readlines(supplier_csv,:headers => true).each do |row|
      s = DistributionPluginSupplier.create_dummy :consumer => node, :name => row[1]
      id_s[row[0]] = s
      email = row[3]
      email = 'rede@terramater.org.br' if email.blank? or !email.include? '@'
      email = email.strip.split(';').first
      puts email if verbose

      s.profile.update_attributes! :contact_phone => row[2], :contact_email => email
      node.profile.admins.each{ |a| s.profile.add_admin a }
    end

    id_p = {}
    CSV.readlines(products_csv,:headers => true).each do |row|
      if row[1] =~  /(.+?) - (.+)/  # check for a description
        name = $1; description = $2
      else
        name = row[1]
        description = ''
      end
      product =  DistributionPluginDistributedProduct.new :node => node, :name => name, :description => description, :active => row[2]
      puts row[1] if product.nil? and verbose
      id_p[row[0]] = product
    end

    CSV.readlines(supplier_products_csv,:headers=> true).each do |row|
      s = id_s[row[0]]
      p = id_p[row[1]]
      puts row[1] if p.nil? and verbose
      p.supplier = s
      print "#{s.name} - #{p.name}"
      print " - p: #{row[2]}" if !row[2].nil? and verbose
      puts " - m: "+ row[3] if !row[3].nil? and verbose
      print "\n\n"
      p.update_attributes :supplier_product => {:price => row[2], :margin_percentage => row[3]}
      p.save!
    end

  end
end
