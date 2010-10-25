class BaseSelector

  def initialize db
    @db = db
    @from = nil
    @where = nil
    @result_set = nil
  end

 def from table, &block
    raise 'more than one from clause' unless @from.nil?
    @from = table
    block_given? ? self.each(&block) : self
  end

  def where &block
    raise 'more than one where clause' unless @where.nil?
    @where = Where.new
    @where.instance_eval &block
    self
  end

  def dump
    raise 'missing from clause' if @from.nil?
    raise NotImplementedError, 'virtual method'
  end

  def each &block
    @result_set = @db.execute dump if @result_set.nil?
    @result_set.each &block
  end

  include Enumerable

  class Where

    def initialize
      @columns = []
    end

    def column
      col = Column.new
      @columns << col
      col
    end

    def dump
      raise 'empty where clause' if @columns.empty?
      'WHERE ' + @columns.map{|c| c.dump }.join(' and ')
    end

    class Column

      def initialize
        @name = nil
        @op = nil # can be '=', '<>' '<', '>', '<=', '>='
        @rval = nil
        @result_set = nil
      end

      def [] name
        raise 'named again' unless @name.nil?
        @name=name
        self
      end

      def == rval
        cmp '=', rval
      end

      def != rval
        cmp '<>', rval
      end

      def < rval
        cmp '<', rval
      end

      def > rval
        cmp '>', rval
      end

      def <= rval
        cmp '<=', rval
      end

      def >= rval
        cmp '>=', rval
      end

      def dump
        raise 'column has no name' if @name.nil?
        raise "column #{@name} has no comparison operator" if @op.nil?
        "#{@name} #{@op} #{@rval.inspect}"
      end

      protected

      def cmp op, rval
        raise "more than one comparison operator detected, already have #{@op}" unless @op.nil?
        @op=op
        @rval=rval
        self
      end

    end

  end

end
