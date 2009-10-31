class Exporter
  extend Loader
  cattr_accessor :models
  self.models = models_from_database
  
  def self.export
    hash = {'name' => 'Last export', 'description' => "Backup of the database as of #{Time.now.to_s(:rfc822)}"}
    hash['records'] = {}
    self.models.each do |klass|
      recs = klass.find(:all)
      if recs
        hash['records'][klass.name.pluralize] = recs.inject({}) { |h, record| h[record.id.to_s] = record.attributes; h }
      end
    end
    hash.to_yaml
  end
end
