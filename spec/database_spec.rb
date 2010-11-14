require 'spec_helper'
require 'minisql/database'

describe MiniSQL::Database do

  include SpecHelperMethods

  before :each do
    init_db
  end

  after :each do
    clean_db
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
    @db.insert_into :tbl, sample_data
    result = @db.select['*'].from(:tbl).to_a
    result.size.should == 1
    record_equal result[0], sample_data
  end

  it 'can select columns from table' do
    create_sample_table
    @db.select[:int_col, :float_col].from(:tbl).to_a.should == []
    @db.insert_into :tbl, sample_data
    result = @db.select[:int_col, :float_col].from(:tbl).to_a
    result.size.should == 1
    record_equal result[0], [42, 2.17]
  end

  it 'can select from table where ...' do
    create_sample_table

    @db.select['*'].from(:tbl).where do
      column[:int_col] < 0
      column[:float_col] > 1
      column[:char_col] != 'abc'
    end.to_a.should == []

    @db.select['*'].from(:tbl).where do
      column[:int_col] >= 0
      column[:float_col] <= 1
      column[:char_col] != 'abc'
    end.to_a.should == []
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
    insert_sample_data [0, 1.0, 'another one     ']
    @db.delete_from :tbl do
      column[:int_col] < 1
    end
    result = @db.select['*'].from(:tbl).to_a
    result.size.should == 1
    record_equal result[0], sample_data
  end

end
