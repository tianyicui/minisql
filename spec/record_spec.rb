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
    record_equal deserialized
  end

  it 'can insert and retrieve records' do
    (0...100).each do |i|
      data = sample_data
      data[0] = i
      @record.insert_record data
    end
    (0...100).each do |i|
      data = sample_data
      data[0] = i
      record_equal @record.read_record(i), data
    end
  end

  def record_equal data, origin=nil
    origin = sample_data unless origin
    data[1].should be_close(origin[1],0.0001)
    data[1] = origin[1]
    data.should == origin
  end

  def block_size
    123
  end

end
