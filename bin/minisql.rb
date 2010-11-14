#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))

require 'minisql'
require 'readline'

db = MiniSQL::Database.new "./minisql.db"

while line = Readline.readline('> ', true)
  begin
    puts db.execute(line).inspect
  rescue Exception => e
    puts e
  end
end
