require 'yaml'

module FunkyWorldCupApp
  class Settings
    @@config = {}

    def self.get(key = nil)
      key.nil? ? @@config : @@config[key]
    end

    def self.load(file_path, env)
      begin
        @@config = YAML.load_file(file_path)[env.to_s]
      rescue => e
        puts e.message
        abort("Can't load settings file")
      end
    end
  end

  class Database
    def self.connect(settings)
      Sequel.connect connection_path(settings)
    end

    private
      def self.connection_path(settings)
        "postgres://#{settings['user']}:#{settings['password']}@#{settings['host']}:#{settings['port']}/#{settings['db_name']}"
      end
  end

  class LoginException < StandardError; end;

  def self.generate_group_link(id = 0)
    new_link = id.to_s + SecureRandom.hex(10)

    if Group.where(:link => new_link).count > 0
      return FunkyWorldCupApp::generate_group_link(id)
    end
    new_link
  end
end

