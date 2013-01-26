module DotRuby

  module Configuration

    class Base

      # Check if a command matches against criteria.
      #
      # @return [Boolean]
      def matching_command?(command, state={})
        exe, *argv = *command.split(/\s+/)
        exe == state[:exename] && argv == state[:argv][0,argv.size]
      end

      # Check if a feature matches against criteria.
      #
      # @return [Boolean]
      def matching_feature?(feature, state={})
        feature == state[:feature]
      end

      # Check if a feature has been require already.
      #
      # FIXME: This is not a perfect solution. Is it even possible with Ruby?
      # Since Ruby provides no way to ask if a feature has been required or not,
      # we can only condition application of pre-extisting constants on a
      # matching command.
      #
      # @return Boolean
      def previously_loaded?(feature)
        feature_path = feature + '.rb' unless feature.end_with?('.rb')
        $LOADED_FEATURES.any? do |path|
          path.end_with?(feature_path)
        end
      end

      # Lookup command feature.
      #
      # @return [String] Feature name.
      def command_feature(command)
        exename = command.split(/\s+/).first
        command_connection(command) || command_connection(exename) || exename
      end

      # Commands are connected to one and only one feature name.
      #
      # @return [String] Feature name.
      def command_connection(command)
        DSL.command_connections(command)
      end

      # Constants can be connected to multiple-commands.
      #
      # @return [Array<String>] List of commands.
      def constant_connections(constant)
        DSL.constant_connections(constant)
      end

      # Return configuration procedure.
      #
      # @return [Proc]
      def to_proc
        @block
      end

    end

  end

end
