require 'yaml'
module Wolfbot
  class Configuration
    SETTINGS_FILE = Wolfbot.root + '/config/settings.yml'
    attr_reader :settings

    def initialize
      @settings = YAML.load_file(SETTINGS_FILE)
    end
  end
end