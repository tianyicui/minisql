module MiniSQL::DSL

  module HasWhere

    def self.included base
      @where = nil
    end

    def where &block
      raise 'more than one where clause' unless @where.nil?
      @where = Where.new
      @where.instance_eval &block
      self
    end

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
        'WHERE ' + @columns.map(&:dump).join(' and ')
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

end
