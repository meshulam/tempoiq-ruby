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

