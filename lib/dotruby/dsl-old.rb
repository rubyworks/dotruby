module DotRuby

  # DotRuby DSL class is used to evaluate the `.ruby` configuration file.
  #
  class DSL < BasicObject #Module
    include ::Kernel

    # Initialize new DSL instance.
    #
    def initialize(file)
      @file = file

      @@default_tags ||= {}
      @@defined_tags ||= {}

      @@contants ||= {}

      instance_eval(::File.read(file), file)
    end

    # The path of the current project's `.ruby` file.
    #
    # @return [String]
    attr :file

    # Return recognizes tags.
    #
    # @return [Hash]
    def tags
      keys = @@default_tags.keys - @@defined_tags.keys
      tags = @@defined_tags.dup
      keys.each do |key|
        tags[key] = [@@default_tags[key]]
      end
      tags
    end

    # Defined tags map constant names to a list of `[command, feature]` pairs.
    #
    # @return [Hash<Array>]
    #def defined_tag
    #end

    # Table of constant configurations.
    #
    # @return [Hash]
    def constants
      @@contants
    end

    # Tag a constant to a command and/or feature.
    #
    def tag(constant, *target)
      options = (::Hash === target.last ? target.pop : {})
      target  = target.first

      command = options[:command] || target
      feature = options[:feature] || target

      tag = [command.to_s, feature.to_s]

      @@defined_tags[constant] ||= []
      @@defined_tags[constant] << tag unless @@defined_tags[constant].include?(tag)
      @@defined_tags
    end

    # Set the default tag for a constant.
    # Unlike defined tags, there can be only one associate for a default tag.
    #
    # @return [Hash<Array>]
    def default_tag(cname, command, feature=nil)
      @@default_tags[cname.to_sym] = [command.to_s, (feature || command).to_s]
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
    # @param [Symbol,String] cname
    #
    # @return [Constant]
    def self.const_missing(cname)
      @@default_tags[cname.to_sym] = [cname.to_s.downcase, cname.to_s.downcase]

      @@contants[cname] ||= Constant.new(cname)
    end

  end

end
