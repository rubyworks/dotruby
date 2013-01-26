module DotRuby

  #
  class Profile

    #
    def self.new(*argv)
      profile = super(*argv)
      DotRuby.profiles << profile
      profile
    end

    # Setup new Profile instance.
    #
    # @param [String,Symbol] name
    #   Profile name.
    #
    # @param [Hash] environment
    #   Environment settings.
    #
    def initialize(*argv)
      case argv.fist
      when Hash
        @name = nil
        @environment = (Hash === argv.last ? argv.pop : {})
      else
        @name, @environment = *argv
      end

      @constants = {}
      @configurations = []
    end

    #
    def name
      @name
    end

    #
    def envinroment
      @environment
    end

    #
    def <<(configuration)
      @configurations << configuration
    end

    #
    def command(name, *argv, options={}, &block)
      self << Configuration::Command.new(name, *argv, options, &block)
    end

    #
    def feature(name, options={}, &block)
      self << Configuration::Feature.new(name, options, &block)
    end

    #
    # 
    #
    def constant(const_name)
      return @constants[const_name.to_sym] if constant?(const_name)

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
      @constants.key?(name.to_sym)
    end


  end

end
