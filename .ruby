tag :RSpec, 'rspec'
tag :Test, 'rubytest'

RSpec.configure do
  p "HELLO!"
end

Test.run do
  p "HELLO!"
end

Test.run('coverage') do
  p "HELLO AGAIN!"
end

Rake.file do
  task :default do
    puts "Default Rake Task!"
  end
end

