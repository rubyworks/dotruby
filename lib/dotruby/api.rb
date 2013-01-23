module DotRuby
  require 'dotruby/dsl'
  require 'dotruby/constant'

  #
  def self.configuration
    @configuration ||= DSL.new(dotruby_file)
  end

  # This is a convenience interfact to the configuration domain, which
  # is useful for tweaks to redefine the default tag.
  def self.default_tag(cname, command, feature=nil)
    configuration.default_tag(cname, command, feature)
  end

  # Configure the system.
  #
  # @return nothing
  def self.configure!
    return unless dotruby_file

    dotruby = DotRuby.configuration

    begin
      require_relative "tweaks/#{DotRuby.command}"
    rescue LoadError
    end

    # If the constant already exists, apply the configuration.
    #
    # Since Ruby provides no way to ask if a feature has been required or not,
    # we can only condition application of pre-extisting constants on a
    # matching command.
    dotruby.tags.each do |cname, tags|
      tags.each do |tag|
        next unless Object.const_defined?(cname)
        next unless DotRuby.command == tag.first  # command of the tag
        if config = dotruby.constants[name]
          execute(&config)
        end
      end
    end

    # If the constant doesn't already exist, wait until it is required.
    ::Kernel.module_eval {
      alias _require require

      def require(fname)
        _require(fname)

        dotruby = DotRuby.configuration
        command = DotRuby.command
        dotruby.tags.each do |cname, tags|
          tags.each do  |tag|
            next unless fname == tag.last     # feature of the tag
            next unless command == tag.first  # command of the tag
            if config = dotruby.constants[cname]
              DotRuby.execute(&config)
            end
          end
        end
      end

      module_function :require
    }
  end

  # Current command.
  #
  # @return [String]
  def self.command
    ENV['command'] || File.basename($0)
  end

  # Execute the configuration.
  #
  # @return nothing
  def self.execute(&config)
    config.call
  end

  # Returns the `.ruby` file of the current project.
  #
  # @return {String] The .ruby file of the project.
  def self.dotruby_file
    file = File.join(project_root, '.ruby')
    return nil unless File.exist?(file)
    return file
  end

  # Find the root directory of the current project.
  #
  # @return [String,nil] The root directory of the project.
  def self.project_root(start_dir=Dir.pwd)
    dir  = start_dir
    home = File.expand_path('~')
    until dir == home || dir == '/'
      if file = Dir[File.join(dir, '{.ruby,.git,.hg}')].first
        return dir
      end
      dir = File.dirname(dir)
    end
    nil
  end

end
