module DotRuby
  require 'dotruby/dsl'
  require 'dotruby/constant'

  # Configure the system.
  #
  # @return nothing
  def self.configure!
    return unless dotruby_file

    begin
      require_relative "tweaks/#{DotRuby.command}"
    rescue LoadError
    end

    $dotruby = DSL.new(dotruby_file)

    # If the constant already exists, apply the configuration.
    $dotruby.constants.each do |name, config|
      if Object.const_defined?(name)
        execute(&config)
      end
    end

    # If the constant doesn't already exist, wait until it is required.
    ::Kernel.module_eval {
      alias _require require

      def require(fname)
        _require(fname)

        if consts = $dotruby.commands[[DotRuby.command, fname]]
          consts.each do |name|
            if config = $dotruby.constants[name]
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
