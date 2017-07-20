module Wolfbot
  def self.config
    @config ||= Configuration.new
  end
  
  def self.root
    @root ||= File.expand_path('../../', __FILE__)
  end
end

require 'wolfbot/channel'
require 'wolfbot/configuration'
require 'wolfbot/twitch'