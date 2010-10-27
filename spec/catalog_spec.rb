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

  it 'can read the table info' do
    create_sample_table
    @catalog.table_info(:tbl).should == sample_table_info
  end

end
