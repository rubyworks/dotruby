require 'pp'

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

  #
  class DSL < BasicObject #Module
    include ::Kernel

    attr :file

    # Table of command/feature to constant relationships.
    #
    # @return [Hash]
    def commands
      @@cmds
    end

    # Table of constant configurations.
    #
    # @return [Hash]
    def constants
      @@cons
    end

    # Initialize new DSL instance.
    #
    def initialize(file)
      @file = file

      @@cmds ||= {}
      @@cons ||= {}

      instance_eval(::File.read(file), file)
    end

    # Tag a constant to a command and/or feature.
    #
    def tag(constant, *target)
      options = (::Hash === target.last ? target.pop : {})
      target  = target.first

      command = options[:command] || target
      feature = options[:feature] || target

      (@@cmds[[command, feature]] ||= []) << constant
    end

    # Constants provide configuration.
    #
    def self.const_missing(name)
      @@cons[name] ||= Constant.new(name)
    end

  end

  # The virtual constant class is a simple recorder. Every method
  # called on it is recorded for later recall on the actual constant
  # given by name.
  #
  # To invoke the recordeed calls on the real constant use `to_proc.call`.
  #
  class Constant < BasicObject

    # Initialize configuration.
    #
    # @param [Symbol] Name of constant.
    #
    def initialize(name)
      @name  = name
      @calls = []
    end

    # An inspection string for the Configuration class.
    #
    # @return [String]
    def inspect
      "#<Constant #{@name}>"
    end

    #
    def method_missing(s, *a, &b)
      @calls << [s, a, b]
    end

    # TODO: Add support for const_missing? But these need
    #       to be recalled in order with method_missing.

    #def const_missing(name)
    #  @calls << Configuration.new("#{@name}::#{name}")
    #end

    # Create a Proc instance that will recall the method
    # invocations on the actual constant.
    #
    # @return [Proc]
    def to_proc
      name, calls = @name, @calls
      ::Proc.new do
        const = ::Object.const_get(name)
        calls.each do |s, a, b|
          const.public_send(s, *a, &b)
        end
      end
    end
  end

  # Configure the system.
  #
  # @return nothing
  def self.configure!
    return unless dotruby_file

    begin
      require_relative "tweaks/#{DotRuby.command}"
    rescue LoadError
    end

    $dotruby = DSL.new(dotruby_file)

    # If the constant already exists, apply the configuration.
    $dotruby.constants.each do |name, config|
      if Object.const_defined?(name)
        execute(&config)
      end
    end

    # If the constant doesn't already exist, wait until it is required.
    ::Kernel.module_eval {
      alias _require require

      def require(fname)
        _require(fname)

        if consts = $dotruby.commands[[DotRuby.command, fname]]
          consts.each do |name|
            if config = $dotruby.constants[name]
              DotRuby.execute(&config)
            end
          end
        end
      end

      module_function :require
    }
  end

  # Current command.
  #
  # @return [String]
  def self.command
    ENV['command'] || File.basename($0)
  end

  # Execute the configuration.
  #
  # @return nothing
  def self.execute(&config)
    config.call
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
