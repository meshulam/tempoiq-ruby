require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |task|
  task.name = :test
  task.libs << "tests"
  task.test_files = FileList["test/unit/test*.rb"]
  task.verbose = true
end

Rake::TestTask.new do |task|
  task.name = :integration
  task.libs << "tests"
  task.test_files = FileList["test/integration/test*.rb"]
  task.verbose = true
end

