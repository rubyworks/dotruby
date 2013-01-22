# DotRuby - Universal Runtime Configuration for Ruby Tools
#
# Q. What if a program needs to be configured, but it does not provide
# an interface via a constant? For example, what if it uses a global
# variable?
#
# A. Most likely the program has a toplevel namespace module. You
# can always call module_eval to handle it if there is no other means.
# You ccould alos define a *make-shift* extension method on it that does
# the dirty deed. If there is no such module, just make a *make-shift*
# module for it too.
#
#    module ProgramWithoutNamespace
#      def self.configure(settings)
#        $dirty_program_settings = settings
#      end
#    end
#
module DotRuby

  def self.profile
    env = ENV['profile'] || ENV['p']
    env ? env.to_sym : nil
  end

  #
  class DSL < BasicObject #Module
    include ::Kernel

    def commands
      @@commands
    end

    def constants
      @@constants
    end

    def initialize(file)
      @file = file

      @@commands  = {}
      @@constants = {}
      @@profile   = nil

      instance_eval(::File.read(file), file)
    end

    #
    # Tag a constant to a command and/or feature.
    #
    def tag(constant, *target)
      options = (::Hash === target.last ? target.pop : {})
      target  = target.first

      command = options[:command] || target
      feature = options[:feature] || target

      (@@commands[[command, feature]] ||= []) << constant
    end

    #
    # TODO: Support nested profiles?
    #
    def profile(name=nil, &block)
      return @@profile unless name or block

      @@profile = name.to_sym
      begin
        block.call
      ensure
        @@profile = nil
      end
    end

    #
    # Constants provide configuration.
    #
    def self.const_missing(name)
      @@constants[@@profile] ||= {}
      @@constants[@@profile][name] ||= Configuration.new(name)
    end

  end

  #
  #
  class Configuration
    def initialize(name)
      @name  = name
      @calls = []
    end

    def __run__
      c = Object.const_get(@name)
      @calls.each do |s, a, b|
        c.public_send(s, *a, &b)
      end
    end

    def method_missing(s, *a, &b)
      @calls << [s, a, b]
    end
  end

  # Boot the system.
  #
  # @return nothing
  def self.boot!
    return unless dotruby_file

    $dotruby = DSL.new(dotruby_file)

    # If the constant already exists, apply the configuration.
    $dotruby.constants[DotRuby.profile].each do |const, config|
      if Object.const_defined?(const)
        config.__run__
      end
    end

    # If the constant doesn't already exist, wait until it is required.
    ::Kernel.module_eval {
      alias _require require

      def require(fname)
        _require(fname)

        if consts = $dotruby.commands[[File.basename($0), fname]]
          consts.each do |c|
            if profile = $dotruby.constants[DotRuby.profile]
              profile[c].__run__
            end
          end
        end
      end
    }
  end

  # Returns the `.ruby` file of the current project.
  #
  # @return {String] The .ruby file of the project.
  def self.dotruby_file
    file = File.join(project_root, '.ruby')
    return nil unless File.exist?(file)
    return file
  end

  # Find the root directory of the current project.
  #
  # @return [String,nil] The root directory of the project.
  def self.project_root(start_dir=Dir.pwd)
    dir  = start_dir
    home = File.expand_path('~')
    until dir == home || dir == '/'
      if file = Dir[File.join(dir, '{.ruby,.git,.hg}')].first
        return dir
      end
      dir = File.dirname(dir)
    end
    nil
  end

end
