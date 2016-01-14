module Bootstrap
  module Utils
    def Utils.Files(*files)
      files.each { |f|
        return File.absolute_path(f) if File.exist?(f)
      }
      nil
    end
  end

  class UserSettings
    
    protected

    def UserSettings.init(file)
      if file.nil?
        @@user_settings = Utils.Files("hf", "bootstrap-hf", "bootstrap")
      else
        @@user_settings = file
      end
      raise LoadError, "not found" unless @@user_settings
			raise LoadError, "not allowed" unless is_user_allowed?(@@user_settings)
      raise LoadError, "require failed" unless load(@@user_settings)
    end

		private

		# Perform the following checks:
		#  - The file must be owned by the current user
		#  - The file must not be world-readable or writable
		#  Beware File.grpowned? will return false on Windows (altough we're not targeting Windows yet)
		def UserSettings.is_user_allowed?(file)
			File.owned?(file) and File.grpowned?(file) and (!File.world_readable?(file) && !File.world_writable?(file))
    end

    def initialize; end
  end

  class Config < UserSettings
    def Config.get_config(file = nil)
      user_config = nil

      begin
        init(file)

        user_config = Bootstrap::UserConfig
        puts "User configuration: " + user_config.to_s
      rescue LoadError => le
        puts "-- [ERROR] Could not load user hooks at '#{@@user_settings}': #{le.message}."
        if le.message.eql?("not allowed")
          puts <<M
-- The file must be owned and group-owned by the same effective id as the running process
-- and not be world-readable or writable.
M
        end
        user_config = nil
      rescue NameError
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
      rescue LoadError
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

    private
    def initialize; end
  end
end
