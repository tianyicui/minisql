require 'minisql'

describe MiniSQL::Database do

  before :each do
    @db = MiniSQL::Database.new db_file
  end

  after :each do
    @db.close
    require 'fileutils'
    FileUtils.rm_rf db_file
  end

  it 'can be initialized and closed' do
  end

  it 'can run SQL' do
    @db.eval do
      tables.should == []
      execute 'create table tbl (id int, primary key (id) );'
      tables.should == [:tbl]
      execute 'drop table tbl;'
      tables.should == []
    end
  end

  it 'can create table' do
    create_sample_table
  end

  it 'can get table list' do
    insert_sample_data
    @db.tables.should == [:tbl]
  end

  it 'can drop table' do
    create_sample_table
    @db.eval do
      drop_table :tbl
      tables.should == []
    end
  end

  #XXX: why rspec don't let me use @db.eval and 'should include' in the same time?
  it 'can select * from table' do
    create_sample_table
    @db.select['*'].from(:tbl).to_a.should == []
    @db.select['*'].from(@db.meta_table).to_a[0].should include('tbl')
  end

  it 'can select columns from table' do
    create_sample_table
    @db.select[:int_col, :float_col].from(:tbl).to_a.should == []
    @db.select[:type, :name].from(@db.meta_table).to_a.should include(['table', 'tbl'])
  end

  it 'can select from table where ...' do
    create_sample_table

    @db.select['*'].from(:tbl).where do
      column[:int_col] < 0
      column[:float_col] > 1
      column[:char_col] != 'abc'
    end.to_a.should == []

    @db.select[:type, :name].from(@db.meta_table).where do
      column[:type] == 'table'
      column[:name] == 'tbl'
    end.to_a.should == [['table', 'tbl']]
  end

  it 'can create and drop index on table' do
    create_sample_table
    @db.eval do
      create_index :char_index, :tbl, :char_col
      drop_index :char_index
    end
  end

  it 'can insert values into table' do
    insert_sample_data
  end

  it 'can delete all data from table' do
    insert_sample_data
    @db.eval do
      delete_from :tbl
      select['*'].from(:tbl).to_a.should == []
    end
  end

  it 'can delete specified data from table' do
    insert_sample_data
    insert_sample_data [0, 1.0, 'another one']
    @db.delete_from :tbl do
      column[:int_col] < 1
    end
    @db.select['*'].from(:tbl).to_a.should == [sample_data]
  end

  def create_sample_table
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

end
