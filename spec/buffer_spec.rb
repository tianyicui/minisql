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

  it 'can set and get one block' do
    test_one_block 7
  end

  it 'can set and get block sequentially' do
    (0..10).each {|i| test_one_block i}
  end

  it 'can set and get block increasingly' do
    (0..10).each { |i| test_one_block i*2 }
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
    enum.reverse.each { |i| test_one_block i }
  end

  def test_one_block num
    block_size = @buffer.block_size
    set = random_string(block_size)
    @buffer.set_block num, set
    renew_buffer @tmp_file
    got = @buffer.get_block(num)
    if set != got
      puts num
      raise
    end
    set.should == got
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
    MiniSQL::Buffer.new(file || new_tmp_file)
  end

  def renew_buffer file=nil
    @buffer.close
    @buffer = new_buffer file
  end

end
