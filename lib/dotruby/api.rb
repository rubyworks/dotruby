module DotRuby
  require 'dotruby/module'
  require 'dotruby/profile'
  require 'dotruby/constant'
  require 'dotruby/dsl'

  #
  #
  def self.configuration
    @configuration ||= DSL.load
  end

  #
  def self.profiles
    configuration.profiles
  end

  #
  def self.connect(*args)
    configuration.connect(*args)
  end

  # Configure the system.
  #
  # @return nothing
  def self.configure!(conf=nil)
    return unless DotRuby.file unless conf

    @configuration = conf if conf

    require_relative 'connects'

    configuration = DotRuby.configuration
    profiles      = configuration.profiles

    begin
      require_relative "tweaks/#{DotRuby.exec}"
    rescue LoadError
    end

    state = {:exec => self.exec, :argv => self.argv}

    profiles.each do |profile|
      next unless profile.applicable?
      profile.configurations.each do |configuration|
        # If connected feature is already required then apply the configuration.
        if configuration.prematch?(state)
          configuration.call
        end
      end
    end

    # If the constant doesn't already exist, wait until it is required.
    ::Kernel.module_eval {
      alias _require require

      def require(fname)
        _require(fname)

        state = {:exec=>DotRuby.exec, :argv=>DotRuby.argv, :feature=>fname}

        DotRuby.profiles.each do |profile|
          next unless profile.applicable?
          profile.configurations.each do |configuration|
            if configuration.postmatch?(state)
              configuration.call
            end
          end
        end
      end

      module_function :require
    }
  end

  # Current command name.
  #
  # @return [String]
  def self.exec
    ENV['exec'] || File.basename($0)
  end

  # Current command arguments.
  #
  # @return [String]
  def self.argv
    ARGV
  end

  # Execute the configuration.
  #
  # @return nothing
  #def self.execute(&config)
  #  config.call
  #end

  # Returns the `.ruby` file of the current project.
  #
  # @return {String] The .ruby file of the project.
  def self.file
    if project_root
      file = File.join(project_root, '.ruby')
      return nil unless File.exist?(file)
      return file
    end
  end

  # Find the root directory of the current project.
  #
  # @return [String,nil] The root directory of the project.
  def self.project_root(start_dir=Dir.pwd)
    dir  = start_dir
    home = File.expand_path('~')
    until dir == home || dir == '/'
      if Dir[File.join(dir, '{.ruby,.git,.hg}')].first
        return dir
      end
      dir = File.dirname(dir)
    end
    nil
  end

end
