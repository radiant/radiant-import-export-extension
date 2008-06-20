  class Exporter
    cattr_accessor :models
    self.models = [Radiant::Config, User, Page, PagePart, Snippet, Layout]
    
    def self.export
      hash = {'name' => 'Last export', 'description' => "Backup of the database as of #{Time.now.to_s(:rfc822)}"}
      hash['records'] = {}
      self.models.each do |klass|
        hash['records'][klass.name.pluralize] = klass.find(:all).inject({}) { |h, record| h[record.id.to_s] = record.attributes; h }
      end
      hash.to_yaml
    end
  end
