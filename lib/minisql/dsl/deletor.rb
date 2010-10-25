module MiniSQL::DSL

  class Deletor

    require 'minisql/dsl/has_where'
    include HasWhere

    def initialize db, table, &block
      @table = table
      where &block if block_given?
      db.execute dump
    end

    def dump
      sql = "DELETE FROM #{@table}"
      sql += ' ' + @where.dump unless @where.nil?
      sql += ' ;'
    end

  end

end
