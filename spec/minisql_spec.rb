require 'minisql'
require 'fileutils'

describe MiniSQL do
  before :each do
    @db = MiniSQL.new db_file
  end

  after :each do
    @db.close
    FileUtils.rm db_file
  end

  it 'can be initialized and closed' do
  end

  it 'can run SQL & get table list' do
    @db.tables.should == []
    @db.execute 'create table tbl (id int);'
    @db.tables.should == [:tbl]
    @db.execute 'drop table tbl;'
    @db.tables.should == []
  end

  it 'can create table' do
    ddl = @db.create_table :tbl do
      column[:int_col].int
      column[:float_col].float
      column[:char_col].char(16).unique
      primary_key :int_col
    end
    ddl.split.should == <<-EOF.split
    CREATE TABLE tbl (
      int_col INT,
      float_col FLOAT,
      char_col CHAR(16) UNIQUE,
      PRIMARY KEY ( int_col )
    );
    EOF
    @db.tables.should include :tbl
  end

  def db_file
    '/tmp/database.db'
  end
end
