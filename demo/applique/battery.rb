When 'iven a `.ruby` file containing' do |text|
  $:.unshift File.expand_path('../fixture', File.dirname(__FILE__))

  ENV.replace({})
  ARGV.replace([])

  # set configuration
  $test_config = DotRuby::DSL.new(:text=>text)
end

When 'we run the command' do |text|
  command = text.strip.sub('$ ','').strip

  args = command.split(/\s+/)

  while (/=/ =~ args.first)
    name, value = args.shift.split('=')
    ENV[name] = value
  end

  #ENV['exec'] = args.shift
  $0 = args.shift
  ARGV.replace(args)

  DotRuby.configure!($test_config)
end

When 'requires the file `/(.*?)/`' do |file|
  require file
end

When 'the result should contain' do |text|
  $result.to_s.assert.include?(text.strip)
end

