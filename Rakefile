gem 'rdoc', '>= 2.4.2'
require 'rdoc/task'
require 'rake/testtask'

task :default => "test:unit"

Rake::TestTask.new do |task|
  task.name = "test:unit"
  task.libs << "tests"
  task.test_files = FileList["test/unit/test*.rb"]
  task.verbose = true
end

Rake::TestTask.new do |task|
  task.name = "test:integration"
  task.libs << "tests"
  task.test_files = FileList["test/integration/test*.rb"]
  task.verbose = true
end

desc 'Generate API documentation'
RDoc::Task.new do |rd|
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.options << '--inline-source'
  rd.options << '--line-numbers'
  rd.options << '--main=README.md'
end

