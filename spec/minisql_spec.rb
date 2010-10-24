require 'minisql'

describe MiniSQL do
  it 'can be initialized' do
    MiniSQL.new db_file
  end

  def db_file
    '/tmp/database.db'
  end
end
