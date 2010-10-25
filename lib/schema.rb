class Schema

  def initialize name
    @name = name
    @columns = []
  end

  class Column

    def initialize
      @name = nil
      @unique = nil
      @type = nil
    end

    def [] name
      raise 'named again' unless @name.nil?
      @name=name
      self
    end

    def unique
      raise 'made unique again' unless @unique.nil?
      @unique=true
      self
    end

    def int
      type 'INT'
      self
    end

    def char num
      type "CHAR(#{num.to_i})"
      self
    end

    def float
      type 'FLOAT'
      self
    end

    def dump
      raise 'column has no name' if @name.nil?
      raise "column #{@name} has no type" if @type.nil?
      "#{@name} #{@type}#{@unique ? ' UNIQUE':''}"
    end

    protected

    def type t
      raise 'column type defined again' unless @type.nil?
      @type=t
    end

  end

  def column
    col = Column.new
    @columns << col
    col
  end

  def primary_key pk
    raise 'primary key already set' unless @pk.nil?
    @pk=pk
  end

  def dump
    raise 'table has no name' if @name.nil?
    raise "table #{@name} has no column" if @columns.empty?
    raise "table #{@name} doesn't set primary key" if @pk.nil?
    sql = "CREATE TABLE #{@name} ( "
    @columns.each do |c|
      sql += c.dump+", "
    end
    sql += "PRIMARY KEY ( #{@pk} )"
    sql += " );"
    sql
  end

end
