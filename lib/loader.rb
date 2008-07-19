module Loader
  def models_from_database
    tables = ActiveRecord::Base.connection.tables
    tables.delete "config"
    models = tables.collect { |table| table.camelize.singularize.constantize rescue nil}.compact
    models << Radiant::Config
    models << Radiant::ExtensionMeta
  end
end