require 'spec_helper'
require 'minisql'

describe MiniSQL::Catalog do

  include SpecHelperMethods

  before do
    init_db
    @catalog = @db.catalog
  end

  after do
    clean_db
  end

  it 'can read a table' do
    create_sample_table
    @catalog.table_info(:tbl).should == sample_table_info
  end

  it 'can read index list' do
    create_sample_table
    @db.create_index :char_index, :tbl, :char_col
    @catalog.indexes.should == [:char_index]
  end

end
