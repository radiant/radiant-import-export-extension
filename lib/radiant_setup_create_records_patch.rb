module Radiant
  class Setup
    def create_records(template)
      records = template['records']
      if records
        puts
        records.keys.each do |key|
          feedback "Creating #{key.to_s.underscore.humanize}" do
            model = model(key)
            model.reset_column_information
            record_pairs = order_by_id(records[key])
            step do
              record_pairs.each do |id, record|
                r = model.new(record)
                r.id = id
                r.save
                # UserActionObserver sets user to null, so we have to update explicitly
                model.update_all({:created_by_id => record['created_by_id']}, {:id => r.id}) if r.respond_to? :created_by_id
              end
            end
          end
        end
      end
    end
  end
end
