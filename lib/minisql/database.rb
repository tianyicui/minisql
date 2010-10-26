module MiniSQL

  class Database

    require 'sqlite3'
    require 'minisql/catalog'
    require 'minisql/parser'

    def initialize filename
      @catalog = Catalog.new filename
      @sqlite = SQLite3::Database.new filename+'/.sqlite'
      @parser = MiniSQL::SQLParser.new
    end

    # create_table :table do
    #   column[:co1].char(16).unique
    #   column[:co2].int
    #   column[:co3].float
    #   primary_key :co2
    # end
    def create_table name, &block
      require 'minisql/dsl/schema'
      schema = DSL::Schema.new(name)
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
      require 'minisql/dsl/selector'
      DSL::Selector.new self
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
      require 'minisql/dsl/deletor'
      DSL::Deletor.new self, table, &block
    end

    def execute command, &block
      puts command if @verbose
      @sqlite.execute command, &block
      begin
        ir = @parser.parse(command).compile
      rescue
        puts command
        fail
      end
      @catalog.execute ir
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
      @sqlite.close
    end

    attr_accessor :verbose

    def verbose!
      @verbose=true
    end

    def eval &block
      instance_eval &block
    end

  end

end
