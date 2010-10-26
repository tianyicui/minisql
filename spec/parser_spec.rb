require 'minisql/parser'

describe MiniSQL::SQLParser do
  before :all do
    @parser = MiniSQL::SQLParser.new
  end

  it 'can parse CREATE TABLE' do
    compile('CREATE TABLE tbl ( int_col INT, float_col FLOAT UNIQUE, char_col CHAR(16), PRIMARY KEY (int_col) );').
      should == [ :create_table,
        { :name => :tbl,
          :columns => [
            { :name => :int_col, :type => :int },
            { :name => :float_col, :type => :float, :unique => true },
            { :name => :char_col, :type => :char, :length => 16 }
          ],
          :primary_key => :int_col
        }
      ]
  end

  it 'can parse DROP TABLE' do
    compile('DROP TABLE tbl;').should == [:drop_table, :tbl]
  end

  it 'can parse CREATE INDEX' do
    compile('CREATE INDEX the_index ON the_table ( the_column );').
      should == [ :create_index,
        { :name => :the_index,
          :table => :the_table,
          :column => :the_column
        }
      ]
  end

  it 'can parse DROP INDEX' do
    compile('DROP INDEX index_name;').should ==
      [ :drop_index, :index_name ]
  end

  def compile str
    parsed = @parser.parse(str)
    parsed.should_not == nil
    parsed.compile
  end
end
