module Loader
  # In most cases singularizing a table's name yields the model's name but in
  # special cases where the model's name is already seen as plural by rails, it
  # expects the table's name to then also be plural (so the model: 'MyData' goes
  # with the table: 'my_data')
  def models_from_database
    tables = ActiveRecord::Base.connection.tables
    tables.delete "config"
    if ENV['SKIP']
      table_names = ENV['SKIP'].split(',')
      table_names.each do |table_to_skip|
        puts "Skipping #{table_to_skip}"
        tables.delete table_to_skip.strip
      end
    end
    models = tables.collect { |table| table.camelize.singularize.constantize rescue nil || table.camelize.constantize rescue nil }.compact
    models << Radiant::Config
  end
  
  def join_tables_from_database
    join_tables = []
    ActiveRecord::Base.connection.tables.each do |table| 
      unless ActiveRecord::Base.connection.primary_key(table)
        join_tables << table
      end
    end
    join_tables.compact
  end
end