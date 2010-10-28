require 'spec_helper'
require 'minisql/buffer'

describe MiniSQL::Buffer do

  include SpecHelperMethods

  before :each do
    @buffer = new_buffer
  end

  after :each do
    @buffer.close
  end

  it 'will create a new buffer file if none exists' do
    File.exists?(@tmp_file).should == true
  end

  it 'will return nil if no such buffer' do
    @buffer.get_block(0).should == nil
    test_one_block 0
    @buffer.get_block(0).should_not == nil
    test_one_block 3
    @buffer.get_block(2).should_not == nil
    @buffer.get_block(4).should == nil
  end

  it 'can set and get one block' do
    test_one_block 7
  end

  it 'can set and get two block' do
    test_blocks [1,0]
  end

  it 'can set and get block sequentially' do
    test_blocks 0..10
    test_blocks (0..10).map{|i| i*2}
  end

  it 'can set and get blocks - test 1' do
    test_blocks (0..10).map {|i| i*2}
    test_blocks (0..10).map {|i| i*2+1}
  end

  it 'can set and get blocks - test 2' do
    test_blocks [3, 5, 7, 1, 2, 0, 4, 3, 5, 7]
  end

  it 'can set and get blocks - test 3' do
    test_blocks (0..100).to_a.shuffle
  end

  def test_blocks enum
    enum.each { |i| test_one_block i }
    renew_buffer
    enum.to_a.reverse.each { |i| test_one_block i }
  end

  def test_one_block num
    block_size = @buffer.block_size
    set = random_string(block_size)
    @buffer.set_block num, set
    renew_buffer @tmp_file
    got = @buffer.get_block(num)
    got.should == set
    @buffer.file.size.should >= num * @buffer.block_size
  end

  def random_string size
    random = Random.new
    result = ''
    size.times do
      result <<= random.rand(0...256).chr
    end
    result
  end

  def new_buffer file=nil
    MiniSQL::Buffer.new(file || new_tmp_file, block_size)
  end

  def block_size
    64
  end

  def renew_buffer file=nil
    @buffer.close
    @buffer = new_buffer file
  end

end
