require 'spec_helper'
require 'minisql/parser'

describe MiniSQL::SQLParser do

  include SpecHelperMethods

  before :all do
    @parser = MiniSQL::SQLParser.new
  end

  before :each do
    @parser.root='expression'
  end

  it 'can parse CREATE TABLE' do
    compile(sample_table_ddl).should == [:create_table, sample_table_info]
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

  it 'can parse SELECT * FROM' do
    compile('SELECT * FROM the_table;').should ==
      [ :select,
        { :table => :the_table,
          :columns => :*
        }
      ]
  end

  it 'can parse SELECT .. FROM' do
    compile('SELECT col1,col2, col3 FROM the_table;').should ==
      [ :select,
        { :table => :the_table,
          :columns => [:col1, :col2, :col3]
        }
      ]
  end

  it 'can parse WHERE clause' do
    @parser.root='where_clause'
    compile("WHERE col0<>'hello'").should == Set.new([ [ :'!=', :col0, 'hello'] ])
  end

  it 'can parse WHERE clause with AND' do
    @parser.root='where_clause'
    compile('WHERE col0>1 AND col1<=3.14')
  end

  it 'can parse SELECT .. FROM .. WHRER' do
    compile("SELECT * FROM the_table WHERE col0=1 AND col1<>'hello' AND col2<0.3 AND col3>=6;").should ==
      [ :select,
        { :table => :the_table,
          :columns => :*,
          :where => Set.new([
            [ :'==', :col0, 1 ],
            [ :'!=', :col1, 'hello' ],
            [ :'<', :col2, 0.3 ],
            [ :'>=', :col3, 6 ]
          ])
        }
      ]
  end

  it 'can parse INSERT INTO' do
    compile("INSERT INTO the_table VALUES ( 0, 1.0, 'lisp', -1, -7.5 );").should ==
      [ :insert_into,
        { :table => :the_table,
          :values => [ 0, 1.0, 'lisp', -1, -7.5 ]
        }
      ]
  end

  it 'can parse DELETE FROM' do
    compile('DELETE FROM the_table ;').should ==
      [ :delete_from,
        { :table => :the_table }
      ]
  end

  it 'can parse DELETE FROM .. WHERE' do
    compile("DELETE FROM the_table WHERE language<>'lisp' AND language<>'dialect of lisp';").should ==
      [ :delete_from,
        { :table => :the_table,
          :where => Set.new([
            [ :'!=', :language, 'lisp' ],
            [ :'!=', :language, 'dialect of lisp' ]
          ])
        }
      ]
  end

  it 'can parse regression test 1' do
    compile('SELECT name FROM sqlite_master WHERE type = "table" ;')
  end

  it 'can parse regression test 2' do
    compile('CREATE TABLE tbl ( int_col INT, float_col FLOAT, char_col CHAR(16) UNIQUE, PRIMARY KEY ( int_col ) );')
  end

  def compile str
    parsed = @parser.parse(str)
    parsed.should_not == nil
    parsed.compile
  end

end
