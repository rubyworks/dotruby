module DotRuby

  module Configuration

    # Command configurations are use when a command is explicitly
    # configured in the .ruby file.
    #
    class Command < Base
      # Setup new command configuration.
      #
      # @param [Hash] options
      # @option options [String] :feature
      # @return nothing
      def initialize(command, options={}, &block)
        @command = command.to_s
        @feature = options[:feature]
        @block   = block
      end

      # A command is typically just the single word, called the *exec*.
      # But it can also have subcommand arguments separated by whitespace.
      #
      # @example 'yard'
      # @example 'yard doc'
      # @return [String]
      def command
        @command
      end

      # Commands can be connected to one and only one feature.
      #
      # @return [String] feature name
      def feature
        @feature ||= command_feature(command)
      end

      # A command is prematched if the current command and subcommands are the same
      # and the connected feature has been previously required.
      #
      # @param [Hash] state
      # @option state [String] :exec
      # @option state [Array<String>] :argv
      # @return [Booolean]
      def prematch?(state)
        matching_command?(command, state) && previously_loaded?(feature)
      end

      # A command is postmatched if the current command and subcommands are the same
      # and the connected feature is being required.
      #
      # @param [Hash] state
      # @option state [String] :exec
      # @option state [Array<String>] :argv
      # @option state [String] :feature
      # @return [Boolean]
      def postmatch?(state)
        matching_command?(command, state) && matching_feature?(feature, state)
      end

      # Run configuration procedure.
      #
      # TODO: instance_eval at toplevel ?
      def call
        @block.call
      end

    end

  end

end
