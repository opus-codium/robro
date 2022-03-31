require "robro/browser"
require "robro/version"

require 'logger'
require 'byebug'

module Robro
  class Error < StandardError; end

  def self.logger
    @@logger ||= Logger.new $stdout
  end

  def self.browser=(browser)
    @@browser = browser
  end

  def self.browser
    @@browser || raise('Browser must be initialized first!')
  end
end
