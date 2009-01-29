module Loader
  # In most cases singularizing a table's name yields the model's name but in
  # special cases where the model's name is already seen as plural by rails, it
  # expects the table's name to then also be plural (so the model: 'MyData' goes
  # with the table: 'my_data')
  def models_from_database
    tables = ActiveRecord::Base.connection.tables
    tables.delete "config"
    models = tables.collect { |table| table.camelize.singularize.constantize rescue nil || table.camelize.constantize rescue nil }.compact
    models << Radiant::Config
  end
end