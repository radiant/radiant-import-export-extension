module Radiant
  class Setup
    def create_records(template)
      records = template['records']
      if records
        puts
        records.keys.each do |key|
          table = key.underscore
          # assume this is an ActiveRecord model if table has column 'id'
          if key == "Radiant::Configs" || ActiveRecord::Base.connection.columns(table).map { |c| c.name }.include?("id")
            feedback "Importing '#{key.to_s.underscore.humanize.titleize}' table data" do
              model = model(key)
              model.reset_column_information
              record_pairs = order_by_id(records[key])
              step do
                record_pairs.each do |id, record|
                  begin
                    #puts "i: #{id}"
                    #puts "r: #{record}"
                    #puts
                    r = model.new(record)
                    r.id = id
                    r.save
                    # UserActionObserver sets user to null, so we have to update explicitly
                    model.update_all({:created_by_id => record['created_by_id']}, {:id => r.id}) if r.respond_to? :created_by_id
                  rescue Exception => e
                    puts "Failed to create record #{id}. Reason: #{e}"
                  end
                end
              end
            end
          else
             feedback "Importing '#{key.to_s.underscore.humanize.titleize}' join table data" do
               table = key.underscore
               record_pairs = records[key].sort
               step do
                 record_pairs.each do |id, record|
                   begin
                     sql = "INSERT INTO #{table} (#{record.keys.join(", ")}) VALUES (#{record.values.join(", ")})"
                     ActiveRecord::Base.connection.execute(sql)
                   rescue Exception => e
                     puts "Failed to create record #{id}. Reason: #{e}"
                   end
                 end
               end          
             end
          end
        end
      end
    end
  end
end
