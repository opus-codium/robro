require "robro/browser"
require "robro/version"

require 'tty/logger'
require 'debug'

module Robro
  class Error < StandardError; end

  def self.logger
    @@logger ||= TTY::Logger.new do |config|
      config.handlers = [
        [:console, { output: $stderr, level: :debug }],
      ]
    end
  end

  def self.browser=(browser)
    @@browser = browser
  end

  def self.browser
    @@browser || raise('Browser must be initialized first!')
  end
end
