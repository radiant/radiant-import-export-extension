namespace :db do
  desc "Import a database template from db/export.yml. Specify the TEMPLATE environment variable to load a different template. This is not intended for new installations, but restoration from previous exports."
  task :import do
    require 'highline/import'
    say "ERROR: Specify a template to load with the TEMPLATE environment variable." and exit unless (ENV['TEMPLATE'] and File.exists?(ENV['TEMPLATE']))
    Rake::Task["db:schema:load"].invoke
    # Use what Radiant::Setup for the heavy lifting
    require 'radiant/setup'
    require 'lib/radiant_setup_create_records_patch'
    setup = Radiant::Setup.new
    
    # Load the data from the export file
    data = YAML.load_file(ENV['TEMPLATE'] || "#{RAILS_ROOT}/db/export.yml")
    
    # Load the users first so created_by fields can be updated
    users_only = {'records' => {'Users' => data['records'].delete('Users')}}
    passwords = []
    users_only['records']['Users'].each do |id, attributes|
      if attributes['password']
        passwords << [attributes['id'], attributes['password'], attributes['salt']]
        attributes['password'] = 'radiant'
        attributes['password_confirmation'] = 'radiant'
      end
    end
    setup.send :create_records, users_only
    
    # Hack to get passwords transferred correctly.
    passwords.each do |id, password, salt|
      User.update_all({:password => password, :salt => salt}, ['id = ?', id])
    end

    # Now load the created users into the hash and load the rest of the data
    data['records'].each do |klass, records|
      records.each do |key, attributes|
        if attributes.has_key? 'created_by'
          attributes['created_by'] = User.find(attributes['created_by']) rescue nil
        end
        if attributes.has_key? 'updated_by'
          attributes['updated_by'] = User.find(attributes['updated_by']) rescue nil
        end
      end
    end
    setup.send :create_records, data
  end
  
  desc "Export a database template to db/export_TIME.yml. Specify the TEMPLATE environment variable to use a different file."
  task :export => ["db:schema:dump"] do
    template_name = ENV['TEMPLATE'] || "#{RAILS_ROOT}/db/export_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.yml"
    File.open(template_name, "w") {|f| f.write Exporter.export }
  end
end