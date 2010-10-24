class Schema

  def initalize name
    @name = name
    @columns = []
  end

  attr_reader :name, :columns, :pk

  class Column

    attr_reader :name, :type, :unique

    def [] name
      raise 'named again' unless @name.nil?
      @name=name
    end

    def unique
      raise 'made unique again' unless @unique.nil?
      @unique=true
      self
    end

    def int
      type='int'
      self
    end

    def char num
      type="char#{num.to_i}"
      self
    end

    def float
      type='float'
      self
    end

    def dump
    end

    private

    def type= type
      raise 'column type defined again' unless @type.nil?
      @type=type
    end

  end

  def column
    col = Column.new
    @columns << col
  end

  def primary_key pk
    raise 'primary key already set' unless @pk.nil?
    @pk=pk
  end

  def dump
    # XXX
    ''
  end

end
