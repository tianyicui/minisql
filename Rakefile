require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new('rspec')

desc "Run all specs with rcov"
RSpec::Core::RakeTask.new('rcov') do |t|
  t.rcov = true
end

task :default => :rspec
