require 'minisql'
require 'fileutils'

describe MiniSQL do
  before :each do
    @db = MiniSQL.new db_file
  end

  after :each do
    @db.close
    FileUtils.rm db_file
  end

  it 'can be initialized and closed' do
  end

  it 'can run SQL' do
    @db.sql 'create table tbl (id int);'
    @db.sql 'drop table tbl;'
  end

  def db_file
    '/tmp/database.db'
  end
end
