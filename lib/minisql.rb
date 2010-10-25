class MiniSQL

  require 'sqlite3'

  def initialize file_name
    @db = SQLite3::Database.new file_name
  end

  # Idea:
  #
  # create_table :table do
  #   column[:co1].char(16).unique
  #   column[:co2].int
  #   column[:co3].float
  #   primary_key :co2
  # end
  def create_table name, &block
    require 'schema'
    schema = Schema.new(name)
    schema.instance_eval(&block)
    command = schema.dump
    execute command
    command # return the DDL
  end

  def drop_table table
    execute "DROP TABLE #{table};"
  end

  def create_index name, table, column
    execute "CREATE INDEX #{name} ON #{table} ( #{column} );"
  end

  def drop_index name
    execute "DROP INDEX #{name}"
  end

  # Idea:
  #
  # rows = select['*'].from(:table)
  #
  # or
  #
  # rows = select['*'].from(:table).where do
  #   column[:co1] == ...
  #   column[:co2] < ...
  #   column[:co3] >= ...
  # end
  #
  # rows.each ... # no sql are executed until here
  def select
    require 'selector'
    Selector.new self
  end

  def insert_into table, values
    execute "INSERT INTO #{table} VALUES ( #{values.map{|v| v.inspect}.join(', ')} );"
  end

  # delete_from(:tbl)
  #
  # OR
  #
  # delete_from(:tbl) do
  #   column[:co1] == ...
  #   ...
  # end
  def delete_from table, &block
    require 'deletor'
    Deletor.new self, table, &block
  end

  def execute command, &block
    puts command if @verbose
    @db.execute command, &block
  end

  def tables
    result = []
    select[:name].from(meta_table).where do
      column[:type] == 'table'
    end.each do |row|
      result << row[0].to_sym
    end
    result
  end

  def meta_table
    :sqlite_master
  end

  def close
    @db.close
  end

  attr_accessor :verbose

  def verbose!
    @verbose=true
  end

  def eval &block
    require 'rspec'
    instance_eval &block
  end

end
