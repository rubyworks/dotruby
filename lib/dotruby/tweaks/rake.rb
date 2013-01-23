require 'rake'

module Rake

  # Use this method to add tasks to Rake.
  def self.file(&config)
    Module.new do
      extend Rake::DSL
      module_eval(&config)
    end
  end

  class Application
    remove_const(:DEFAULT_RAKEFILES)
    DEFAULT_RAKEFILES = ['rakefile', 'Rakefile', 'rakefile.rb', 'Rakefile.rb', '.ruby']
    #DEFAULT_RAKEFILES << '.ruby'
  end

  def self.load_rakefile(path)
    case File.basename(path)
    when '.ruby'
      # do nothing, DotRuby will do it
    else
      load(path)
    end
  end

end

