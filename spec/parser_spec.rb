require 'minisql/parser'

describe MiniSQL::SQLParser do
  before :all do
    @parser = MiniSQL::SQLParser.new
  end

  before :each do
    @parser.root='expression'
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
    compile('WHERE col0=1').should == Set.new([ [ :'==', :col0, 1] ])
  end

  it 'can parse WHERE clause with AND' do
    @parser.root='where_clause'
    compile("WHERE col0=1 AND col1<>'hello' AND col2<0.3 AND col3>=6")
  end

  it 'can parse SELECT .. FROM .. WHRER' do
    compile("SELECT * FROM the_table WHERE col0=1 AND col1<>'hello' AND col2<0.3 AND col3>=6;").should ==
      [ :select,
        { :table => :the_table,
          :columns => '*',
          :where => Set.new([
            [ :'==', :col0, 1 ],
            [ :'!=', :col1, 'hello' ],
            [ :'<', :col2, 0.3 ],
            [ :'>=', :col3, 6 ]
          ])
        }
      ]
  end

  def compile str, verbose=false
    parsed = @parser.parse(str)
    parsed.should_not == nil
    if verbose
      puts '==='
      print parsed.inspect
      puts '==='
    end
    parsed.compile
  end
end
