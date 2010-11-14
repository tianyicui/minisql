require 'simplecov'
SimpleCov.start

require 'rspec'

module SpecHelperMethods

  def init_db
    @db = TestDB.new new_tmp_file
  end

  def clean_db
    @db.close
  end

  def create_sample_table
    @db.create_table :tbl do
      column[:int_col].int
      column[:float_col].float
      column[:char_col].char(16).unique
      primary_key :int_col
    end

    info = @db.catalog.table_info(:tbl)
    info.should == sample_table_info

    @db.tables.should include :tbl
  end

  def sample_table_ddl
    <<-EOF
    CREATE TABLE tbl (
      int_col INT,
      float_col FLOAT,
      char_col CHAR(16) UNIQUE,
      PRIMARY KEY ( int_col )
    );
    EOF
  end

  def sample_table_info
    { :name => :tbl,
      :columns => [
        { :name => :int_col, :type => :int },
        { :name => :float_col, :type => :float },
        { :name => :char_col, :type => :char, :length => 16, :unique => true }
      ],
      :primary_key => :int_col
    }
  end

  def insert_sample_data data=nil
    create_sample_table unless @db.tables.include? :tbl
    data = sample_data if data.nil?
    @db.insert_into :tbl, data
    @db.select['*'].from(:tbl).where do
      column[:int_col] == data[0]
      column[:float_col] == data[1]
      column[:char_col] == data[2]
    end.each do |item|
      record_equal item, data
    end
  end

  def sample_data
    [42, 2.17, 'resolution, wow!']
  end

  def new_tmp_file
    @tmp_file = tmp_file
    if File.exist? @tmp_file
      require 'fileutils'
      FileUtils.rm_rf @tmp_file
    end
    return @tmp_file
  end

  def tmp_file
    '/tmp/database.db'
  end

  def new_buffer file=nil
    MiniSQL::CachedBuffer.new(file || new_tmp_file, block_size)
  end

  def record_equal data, origin=nil
    origin = sample_data unless origin
    data[1].should be_close(origin[1],0.0001)
    data[1] = origin[1]
    data.should == origin
  end

end

require 'minisql'

class TestDB < MiniSQL::Database

  include SpecHelperMethods
  include RSpec::Matchers

  def initialize filename
    super(filename)
    require 'sqlite3'
    @sqlite = SQLite3::Database.new filename+'/.sqlite'
  end

  def execute command
    sqlite_result = @sqlite.execute(command).to_a
    my_result = super(command)
    sqlite_result.each_with_index do |v,i|
      record_equal v, my_result[i]
    end
  end

  def close
    @sqlite.close
  end

end
