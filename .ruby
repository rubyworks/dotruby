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


profile :dev do

  Test.run do
    p "DEVELOPMENT SAYS HELLO TOO!"
  end

end

