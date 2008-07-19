namespace :db do
  desc "Import a database template from db/export.yml. Specify the TEMPLATE environment variable to load a different template. This is not intended for new installations, but restoration from previous exports."
  task :import => ["db:remigrate", "db:remigrate:extensions"] do
    say "ERROR: Specify a template to load with the TEMPLATE environment variable." and exit unless (ENV['TEMPLATE'] and File.exists?(ENV['TEMPLATE'])) or File.exists?("#{RADIANT_ROOT}/db/export.yml")
    
    # Use what Radiant::Setup for the heavy lifting
    require 'radiant/setup'
    setup = Radiant::Setup.new
    
    # Load the data from the export file
    data = YAML.load_file(ENV['TEMPLATE'] || "#{RAILS_ROOT}/db/export.yml")
    
    # Load the users first so created_by fields can be updated
    users_only = {'records' => {'Users' => data['records'].delete('Users')}}
    passwords = []
    salts = []
    users_only['records']['Users'].each do |id, attributes|
      if attributes['password']
        passwords << [attributes['id'], attributes['password']]
        salts << [attributes['id'], attributes['salt']]
        attributes['password'] = 'radiant'
        attributes['password_confirmation'] = 'radiant'
      end
    end
    setup.send :create_records, users_only
    # Hack to get passwords transferred correctly.
    passwords.each do |id, password|
      User.update_all({:password => password}, ['id = ?', id])
    end
    # Hack to get salts transferred correctly.
    salts.each do |id, salt|
      User.update_all({:salt => salt}, ['id = ?', id])
    end
    
    # Now load the created users into the hash and load the rest of the data
    data['records'].each do |klass, records|
      records.each do |key, attributes|
        if attributes.has_key? 'created_by'
          attributes['created_by'] = User.find(attributes['created_by'])
        end
      end
    end
    setup.send :create_records, data
  end
  
  desc "Export a database template to db/export.yml. Specify the TEMPLATE environment variable to use a different file."
  task :export => :environment do
    template_name = ENV['TEMPLATE'] || "#{RAILS_ROOT}/db/export.yml"
    File.open(template_name, "w") {|f| f.write Exporter.export }
  end
end