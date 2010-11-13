require 'spec_helper'
require 'minisql/database'
require 'minisql/record'

describe MiniSQL::Record do

  include SpecHelperMethods

  before :each do
    init_db
    create_sample_table
    @catalog = @db.catalog
    @buffer = new_buffer
    @record = MiniSQL::Record.new @catalog.table_info(:tbl), @buffer,
      lambda do |new_table_info|
        @catalog.drop_table :tbl
        @catalog.create_table new_table_info
      end
  end

  after :each do
    clean_db
    @buffer.close
  end

  it 'can be initialized and closed' do
  end

  def block_size
    1024
  end

end
