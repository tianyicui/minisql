require 'minisql/parser'

describe MiniSQL::SQLParser do
  before :all do
    @parser = MiniSQL::SQLParser.new
  end

  it 'can parse DROP TABLE' do
    compile('DROP TABLE tbl;').should == [:drop_table, :tbl]
  end

  it 'can parse CREATE TABLE' do
    compile('CREATE TABLE tbl ( int_col INT, float_col FLOAT UNIQUE, char_col CHAR(16), PRIMARY KEY (int_col) );').
      should == [ :create_table,
        { :name => :tbl,
          :columns => [
            { :name => :int_col, :type => 'int' },
            { :name => :float_col, :type => 'float', :unique => true },
            { :name => :char_col, :type => ['char', 16] }
          ],
          :primary_key => :int_col
        }
      ]
  end

  def compile str
    @parser.parse(str).compile
  end
end
