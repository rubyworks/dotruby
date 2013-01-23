puts "DotRuby in Action!"

RSpec.configure do |c|
  p "Hello from RSpec Config!"
end

Test.run do
  p "HELLO!"
end

Test.run('coverage') do
  p "HELLO AGAIN!"
end

Rake.file do
  task :default => [:test]

  desc "Run unit tests"
  task :test do
    sh 'rubytest'
  end
end

