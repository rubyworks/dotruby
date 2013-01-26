module DotRuby

  #
  class Profile

    # Setup new Profile instance.
    #
    # @param [String,Symbol] name
    #   Profile name.
    #
    # @param [Hash] environment
    #   Environment settings.
    #
    def initialize(name, env=nil)
      if Hash === name
        env, name = name, nil
      else
        env = {}
      end

      @name, @env = name, {}

      env.each do |k,v|
        @env[k.to_s] = v.to_s
      end

      @consts  = {}
      @configs = []
    end

    #
    def applicable?(env=ENV)
      if @name
        return false unless (@name === (ENV['profile'] || ENV['p']))
      end

      @env.all? do |name, value|
        env[name] == value
      end
    end

    # Name of the profile, if not an environment profile.
    #
    # @return [String]
    def name
      @name
    end

    #
    #
    # @return [Hash]
    def env
      @env
    end

    alias :environment :env

    #
    #
    # @return [Array]
    def configs
      @configs
    end

    alias :configurations :configs

    # Add a configuration instance to the profile.
    #
    # @return [Array]
    def <<(configuration)
      @configs << configuration
    end

    #
    #
    # @return [Configuration::Command]
    def command(command, options={}, &block)
      self << Configuration::Command.new(command, options, &block)
    end

    #
    # @return [Configuration::Feature]
    def feature(feature, options={}, &block)
      self << Configuration::Feature.new(feature, options, &block)
    end

    # Get the virtual constant for the given constant name.
    #
    # @return [VirtualConstant]
    def constant(const_name)
      return @consts[const_name.to_sym] if constant?(const_name)

      constant = VirtualConstant.new(const_name)

      self << Configuration::Constant.new(constant)

      return constant
    end

    #
    # Check the constants table to see if the profile has a
    # virtual constant by the given name.
    #
    # @param [#to_sym] name
    #   The constants name.
    #
    # @return [Boolean]
    #
    def constant?(name)
      @consts.key?(name.to_sym)
    end

  end

end
