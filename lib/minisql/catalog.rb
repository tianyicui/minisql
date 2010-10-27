require 'yaml'
require 'fileutils'

module MiniSQL

  class Catalog

    def initialize filename
      @root = Pathname(filename) + 'catalog'
      FileUtils.mkdir_p @root
      @table_catalog = EntityCatalog.new 'table', @root + 'tables'
      @index_catalog = EntityCatalog.new 'index', @root + 'indexes'
    end

    class EntityCatalog

      def initialize kind, path
        @kind=kind
        FileUtils.mkdir_p path
        @path=path
      end

      def entities
        Dir["#{@path}/*"].map{|f| f.basename}
      end

      def create info
        raise "#{kind} info does not specify #{kind} name" unless info[:name]
        name = info[:name].to_s
        file = entity_file(name, false)
        File.open(file, 'w') do |io|
          io << info.to_yaml
        end
      end

      def read name
        file = entity_file(name)
        YAML.load_file file
      end

      def delete name
        file = entity_file(name.to_s)
        FileUtils.rm file
      end

      protected

      def entity_file name, should_exist=true
        file = @path+name.to_s
        if should_exist
          raise "#{@kind} named #{name} doesn't exist" unless file.exist?
        else
          raise "#{@kind} named #{name} already exists" if file.exist?
        end
        file
      end

    end

    def tables
      @table_catalog.entities
    end

    def create_table info
      @table_catalog.create info
    end

    def table_info name
      @table_catalog.read name
    end

    def drop_table name
      @table_catalog.delete name
    end

    def indexes
      @index_catalog.entities
    end

    def create_index info
      @index_catalog.create info
    end

    def drop_index name
      @index_catalog.delete name
    end

    def execute info
      command = info.first
      send(command, info[1]) if respond_to? command
    end

  end

end
