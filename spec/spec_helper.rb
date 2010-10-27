require 'simplecov'
SimpleCov.start

require 'rspec'

module SpecHelperMethods

  def init_db
    @db = MiniSQL::Database.new db_file
  end

  def clean_db
    @db.close
    require 'fileutils'
    FileUtils.rm_rf db_file
  end

  def create_sample_table
    ddl = @db.create_table :tbl do
      column[:int_col].int
      column[:float_col].float
      column[:char_col].char(16).unique
      primary_key :int_col
    end

    ddl.split.should == sample_table_ddl.split
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
    @db.eval do
      insert_into :tbl, data
      select['*'].from(:tbl).where do
        column[:int_col] == data[0]
        column[:float_col] == data[1]
        column[:char_col] == data[2]
      end.to_a.should == [data]
    end
  end

  def sample_data
    [42, 2.17, 'resolution']
  end

  def db_file
    '/tmp/database.db'
  end

  def sqlite_meta_table
    'sqlite_master'
  end

end