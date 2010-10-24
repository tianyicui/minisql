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
  def create_table name, &schema
  end

  def drop_table name
  end

  def create_index name, table, column
  end

  def drop_index name
  end

  # Idea:
  #
  # select('*').from(:table).where do
  #   column[:co1] = ...
  #   column[:co2] < ...
  #   column[:co3] > ...
  # end
  def select columns
  end

  def sql command
  end

end
