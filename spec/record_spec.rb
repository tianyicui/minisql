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
    insert_records
    (0...100).to_a.shuffle.each do |i|
      data = sample_data
      data[0] = i
      record_equal @record.read_record(i), data
    end
  end

  it 'can delete records' do
    insert_records
    @record.delete_record 7
    @record.size.should == 99
  end

  it 'can delete records' do
    insert_records
    func = lambda {|i| i[0]%3==0}
    @record.delete_records func
    @record.select_records(func).size.should == 0
    @records.size.should == 66
  end

  it 'can select records' do
    insert_records
    meta_func = lambda {|i| lambda{|x| x[0]%3==i}}
    @record.select_records(meta_func[0]).size.should == 34
    @record.select_records(meta_func[1]).size.should == 33
    @record.select_records(meta_func[2]).size.should == 33
  end

  it 'can update record' do
    insert_records
    @record.update_record(7,sample_data)
    record_equal @record.read_record(7), sample_data
  end

  it 'can update records' do
    insert_records
    func = lambda {|i| i[0]%3==0}
    @record.update_records func, lambda{|i| i[0]=9875321; i}
    @record.size.should == 100
    @record.select_records(func).should == []
    @record.select_records(lambda{|i| i[0]==9875321}).size.should == 34
  end

  def insert_records data_gen=lambda{|x| x}
    (0...100).each do |i|
      data = sample_data
      data[0] = data_gen[i]
      @record.insert_record data
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
