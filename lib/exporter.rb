class Exporter
  extend Loader
  cattr_accessor :models, :join_tables
  self.models = models_from_database
  self.join_tables = join_tables_from_database
  
  def self.export
    hash = {'name' => 'Last export', 'description' => "Backup of the database as of #{Time.now.to_s(:rfc822)}"}
    hash['records'] = {}
    self.models.each do |klass|
      recs = klass.find(:all)
      if recs
        hash['records'][klass.name.pluralize] = recs.inject({}) { |h, record| h[record.id.to_s] = record.attributes; h }
      end
    end
    self.join_tables.each do |table|
      recs =  ActiveRecord::Base.connection.select_all("SELECT * FROM #{table}")
      if recs
        i = 0
        hash['records'][table.camelize] = recs.inject({}) { |h, record| h[i += 1] = record; h }
      end
    end
    hash.to_yaml
  end
end
