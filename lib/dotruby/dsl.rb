module DotRuby
  require_relative 'configs/base'
  require_relative 'configs/feature'
  require_relative 'configs/command'
  require_relative 'configs/constant'

  #
  #
  class DSL < BasicObject
    include ::Kernel

    #
    class NestingError < ::SyntaxError
    end

    #
    def self.command_connections(command)
      @@command_connections[command]
    end

    #
    def self.constant_connections(constant)
      @@constant_connections[constant]
    end

    #
    def initialize(file)
      @file = file

      # What a crazy awesome line of code!
      @profiles = [@@_profile = @default_profile = ::DotRuby::Profile.new(nil)]

      @@command_connections  = {}
      @@constant_connections = {}

      instance_eval(::File.read(file), file)
    end

    # List of profiles.
    # 
    # @return [Array]
    def profiles
      @profiles
    end

    # Connect a constant to the feature from which it derives.
    #
    #   connect :constant=>:RSpec, :feature=>'rspec/core'
    #
    # Connect a constant to a command that utilizes it for configuration.
    #
    #   connect :constant=>:RSpec, :command=>'rspec'
    #
    # Or connect both at the same time.
    #
    #   connect :constant=>:RSpec, :feature=>'rspec/core', :command=>'rspec'
    #
    # Repeated calls for the same constant will *add* additional commands and features.
    #
    # A command can also be connected to a feature, without any constant.
    #
    #   connect :command=>'rspec', :feature=>'rspec/core'
    #
    # Finally, the `:to` option can be used to assign whatever is not explicitly stated.
    # For example,
    #
    #   connenct :constant=>:QED, :to=>'qed'
    #
    # is equivalent to
    #
    #   connenct :constant=>:QED, :command=>'qed', :feature=>'qed'
    #
    def connect(*target)
      options = (::Hash === target.last ? target.pop : {})

      constant = target.first || options[:constant]

      command = options[:command] || options[:to]
      feature = options[:feature] || options[:to]

      if constant
        connections = (@@constant_connections[constant] ||= [])
        if feature && !command
          old = connections.find{ |c| c[:feature] && !c[:command] }
          connections.delete(old)
          connections << {:feature => feature}
        elsif command && !feature
          connections << {:command=>command}
        else
          connections << {:feature=>feature, :command=>command}
        end
      else
        @@command_connections[command] = feature
      end
    end

    # Import configuration from an external source.
    #
    # @param [Symbol,String] Name of constant or file path.
    #
    # @return nothing
    def import(name, options={})
      raise 'import is not implemented yet'
    end

    #
    #
    def profile(name, env={}, &block)
      raise NestingError if @@_profile
      @@_profile = Profile.new(env)
      @profiles << @@_profile
      begin
        block.call
      ensure
        @@_profile = @default_profile
      end
    end

    #
    #
    def environment(env={}, &block)
      raise NestingError if @@profile
      @@_profile = Profile.new(env)
      @profiles << @@_profile
      begin
        block.call
      ensure
        @@_profile = @default_profile
      end
    end

    #
    #
    def command(command, options={}, &block)
      @@_profile.command(command, options, &block)
    end

    # @deprecate ?
    #
    def feature(name, options={}, &block)
      @@_profile.feature(name, options, &block)
    end

    #
    #
    def self.const_missing(const_name)
      @@_profile.constant(const_name)
    end

  end

end
