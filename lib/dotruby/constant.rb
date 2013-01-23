module DotRuby

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

end
