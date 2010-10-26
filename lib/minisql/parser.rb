require 'treetop'
[
  'keywords',
  'common',
  'create_table_exp',
  'drop_table_exp',
  'create_index_exp',
  'drop_index_exp',
  'select_exp',
  'insert_into_exp',
  'grammar'
].each do |f|
  Treetop.load (Pathname(__FILE__).dirname+"parser/#{f}").to_s
end
