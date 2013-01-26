module DotRuby

  module Configuration

    # A Feature configuration is the simplist type of configuration.
    # It is applied whenever a paticular feature has been loaded.
    #
    # IMPORTANT: This kind of configuration may be deprecated b/c it is
    #            so low-level and broad.
    #
    class Feature < Base
      # Setup new Feature instance.
      #
      # @param [String] fname
      #   The feature's name.
      #
      def initialize(fname, options={}, &block)
        @feature = fname
        @block   = block
      end

      # The feature's name.
      #
      # @return [Sting] The feature name.
      def feature
        @feature
      end

      # A feature is prematched if it has already been required.
      #
      # @param [Hash] state
      # @return [Boolean]
      def prematch?(state)
        previously_loaded?(feature)
      end

      # A feature is postmatched once the feature has been required.
      #
      # @param [Hash] state
      # @option state [String] :exec
      # @option state [Array<String>] :argv
      # @return [Boolean]
      def postmatch?(state)
        state[:exec] ||= DotRuby.exec
        state[:argv] ||= DotRuby.argv
        matching_feature?(feature)
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
