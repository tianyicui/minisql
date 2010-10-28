require 'spec_helper'
require 'minisql/buffer'

describe MiniSQL::Buffer do

  include SpecHelperMethods

  before :each do
    @buffer = MiniSQL::Buffer.new tmp_file
  end

  after :each do
    @buffer.close
    clean_tmp_file
  end

end
