module DotRuby

  module Configuration

    # Constant-based configurations are used when a constant is a receiver
    # at the toplevel of the .ruby file.
    #
    class Constant < Base

      # Setup new constant configuration.
      #
      # @param [VirtualConstant] constant
      # @return nothing
      def initialize(constant)
        @constant = constant
      end

      # The constant.
      #
      # @return [VirtualConstant]
      def constant
        @constant
      end

      # The constant's name.
      #
      # @return [String]
      def name
        @constant.name
      end

      # Constants can have multiple connections. But they can only have a single feature-only
      # connection. Among the other connections, it the connection is only to a command, then
      # that commands feature connection is also the constants feature connection.
      #
      # @return [Array]
      def connections
        constant_connections(name) || [{:command=>name.to_s.downcase, :feature=>name.to_s.downcase}]
      end

      # A constant configuraiton is prematched if the current command and subcommands match one
      # of the commands connected to the constant and the connected feature of that command has been
      # previously required.
      #
      # @return [Booolean]
      def prematch?(state)
        connections.find do |connection|
          command = connection[:command] || constant.to_s.downcase
          feature = connection[:feature] || command_feature(command) || command
          matching_command?(command, state) && previously_loaded?(feature)
        end
      end

      # A constant configuraiton is postmatched if the current command and subcommands match one
      # of the commands connected to the constant and the connected feature of that command is 
      # being required.
      #
      # @return [Booolean]
      def postmatch?(state)
        connections.find do |connection|
          command = connection[:command] || constant.to_s.downcase
          feature = connection[:feature] || command_feature(command) || command
          matching_command?(command, state) && matching_feature?(feature, state)
        end
      end

      # Run configuration procedure.
      #
      def call
        @constant.to_proc.call
      end

    end

  end

end
