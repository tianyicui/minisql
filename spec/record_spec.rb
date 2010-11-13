require 'spec_helper'
require 'minisql/database'
require 'minisql/record'

describe MiniSQL::Record do

  include SpecHelperMethods

  before :each do
    init_db
    create_sample_table
    @catalog = @db.catalog
    @buffer = new_buffer "#{tmp_file}/buffer"
    @record = MiniSQL::Record.new(@catalog.table_info(:tbl), @buffer,
      lambda do |new_table_info|
        @catalog.drop_table :tbl
        @catalog.create_table new_table_info
      end)
  end

  after :each do
    @buffer.close
    clean_db
  end

  it 'can be initialized and closed' do
  end

  it 'can serialize and deserialize item' do
    serialized = @record.serialize(sample_data)
    serialized.size.should == @record.record_size

    deserialized = @record.deserialize(serialized)
    deserialized[1].should be_close(sample_data[1],0.01)

    deserialized[1] = sample_data[1]
    deserialized.should == sample_data
  end

  def block_size
    1024
  end

end
