module MiniSQL

  class Database

    require 'minisql/catalog'
    require 'minisql/parser'

    class Records
      require 'minisql/record'

      def initialize filename, catalog
        @root = Pathname(filename) + 'records'
        require 'fileutils'
        FileUtils.mkdir_p @root
        @catalog = catalog

        @records = {}
        catalog.tables.each do |table|
          add_record(table)
        end
      end

      attr_reader :catalog

      def create_table info
        add_record info[:name]
        []
      end

      def select info
        records[info[:table]].select(info[:columns], info[:where])
      end

      def insert_into info
        records[info[:table]].insert_record(info[:values])
        []
      end

      def delete_from info
        records[info[:table]].delete_from(info[:where])
        []
      end

      def execute info
        command = info.first
        return send(command, info[1]) if respond_to? command
        []
      end

      protected

      attr_reader :records, :root

      def add_record table
        records[table] = get_record(table)
      end

      def get_record table
        table_info = catalog.table_info(table)
        buffer = CachedBuffer.new root + table.to_s
        records[table] = Record.new(table_info, buffer,
          lambda do |new_table_info|
            @catalog.drop_table table
            @catalog.create_table new_table_info
          end)
      end

    end

    def initialize filename
      @catalog = Catalog.new filename
      @records = Records.new filename, @catalog
      @parser = SQLParser.new
    end

    attr_reader :catalog

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
    end

    def drop_table table
      execute "DROP TABLE #{table};"
    end

    def create_index name, table, column
      execute "CREATE INDEX #{name} ON #{table} ( #{column} );"
    end

    def drop_index name
      execute "DROP INDEX #{name};"
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
      execute "INSERT INTO #{table} VALUES ( #{values.map(&:inspect).join(', ')} );"
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

    def execute command
      begin
        hash = @parser.parse(command).compile
      rescue
        raise "Parse error"
      end
      @catalog.execute hash
      @records.execute hash
    end

    def tables
      @catalog.tables
    end

    def eval &block
      instance_eval &block
    end

  end

end
