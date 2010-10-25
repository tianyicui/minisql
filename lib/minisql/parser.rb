require 'treetop'
Treetop.load (Pathname(__FILE__).dirname+"parser/grammar.treetop").to_s
