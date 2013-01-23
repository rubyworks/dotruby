module DotRuby

  #
  class DSL < BasicObject #Module
    include ::Kernel

    # Initialize new DSL instance.
    #
    def initialize(file)
      @file = file

      @@cmds ||= {}
      @@cons ||= {}

      instance_eval(::File.read(file), file)
    end

    # The path of the current project's `.ruby` file.
    #
    # @return [String]
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

    # Tag a constant to a command and/or feature.
    #
    def tag(constant, *target)
      options = (::Hash === target.last ? target.pop : {})
      target  = target.first

      command = options[:command] || target
      feature = options[:feature] || target

      (@@cmds[[command, feature]] ||= []) << constant
    end

    # Only configure if profile matches.
    #
    # @param [#===] match
    #   A String or Regexp or any other object that can 
    #   check a match to a String via #===.
    #
    # @return nothing
    def profile(match, &block)
      if match === (ENV['profile'] || ENV['p'])
        block.call
      end
    end

    # Only configure if environment matches.
    #
    # @param [Hash<name,#===>] matches
    #   A Hash of String or Regexp or any other object that can 
    #   check a match to a String via #===.
    #
    # @todo Should it be logical-or or logical-and?
    #
    # @return nothing
    def environment(matches={}, &block)
      if matches.any?{ |e, m| m === ENV[e] }
        block.call
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

    # Constants provide configuration.
    #
    # @param [Symbol,String] name
    #
    # @return [Constant]
    def self.const_missing(name)
      @@cons[name] ||= Constant.new(name)
    end

  end

end
