require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList["tests/**/test_*.rb"]
  t.libs.push "test"
  t.pattern = "test/**/*_test.rb"
  t.warning = true
  t.verbose = true
end

task default: :test
