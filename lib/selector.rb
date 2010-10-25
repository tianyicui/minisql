require 'has_where'

class Selector

  include HasWhere

  def initialize db
    @db = db
    @from = nil
    @columns = []
    @result_set = nil
  end

  def from table, &block
    raise 'more than one from clause' unless @from.nil?
    @from = table
    block_given? ? self.each(&block) : self
  end

  def [] *columns
    raise 'already defined columns' unless @columns.empty?
    @columns = columns
    self
  end

  include Enumerable
  def each &block
    @result_set = @db.execute dump if @result_set.nil?
    @result_set.each &block
  end

  def dump
    raise 'missing from clause' if @from.nil?
    raise 'columns not defined' if @columns.empty?
    sql = 'SELECT ' + @columns.join(', ') + " FROM #{@from}"
    sql += ' ' + @where.dump unless @where.nil?
    sql += ' ;'
    sql
  end

end
