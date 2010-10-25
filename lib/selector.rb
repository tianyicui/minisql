require 'base_selector'

class Selector < BaseSelector

  def initialize db
    super db
    @columns = []
  end

  def [] *columns
    raise 'already defined columns' unless @columns.empty?
    @columns = columns
    self
  end

  def dump
    super
  rescue NotImplementedError
    raise 'columns not defined' if @columns.empty?
    sql = 'SELECT ' + @columns.join(', ') + " FROM #{@from}"
    sql += ' ' + @where.dump unless @where.nil?
    sql += ' ;'
    sql
  end

end
