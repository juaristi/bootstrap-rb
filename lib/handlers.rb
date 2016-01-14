module Bootstrap
  module Utils
    def Utils.Files(*files)
      files.each { |f|
        return f if File.exist?(f)
      }
      nil
    end

    def Utils.Dirs(*dirs)
      dirs.each { |d|
        return d if Dir.exist?(d)
      }
      nil
    end
  end

  class UserSettings
    protected
    def UserSettings.init
      @@user_settings = Utils.Files("bootstrap", "bootstrap.rb", "bootstrap-rb")
      raise LoadError, "not found" unless @@user_settings
      raise LoadError unless require_relative(@@user_settings)
    end
    def initialize; end
  end

  class Config < UserSettings
    def Config.get_config
      user_config = nil

      begin
        init

        user_config = Bootstrap::UserConfig
        puts "User configuration: " + user_config.to_s
      rescue LoadError => le
        puts "-- [WARNING] Could not load user hooks at '#{@@user_settings}'."
        user_config = nil
      rescue NameError => ne
        user_config = nil
      end

      user_config
    end
  end
  class Handlers < UserSettings
    def Handlers.get_handlers
      user_handlers = nil

      begin
        init
        user_handlers = UserHandlers.new
      rescue LoadError => e
        user_handlers = Handlers.new
        puts "-- [WARNING] Could not load user hooks at '#{user_hooks}'."
      end

      user_handlers
    end

    def post_checkout(info)
      DefaultHandlers.post_checkout(info)
    end
  end

  class DefaultHandlers
    def DefaultHandlers.post_checkout(info)
      puts "-- This is the default 'post_checkout'."
    end
  end
end
