require 'robro'

require 'thor'

module Robro
  class CLI < Thor
    desc 'browse URL', 'Start browser at URL, drop a shell'
    method_option :browser, :type => :string, :description => 'Supported values: firefox or chromium', :default => 'chrome'
    def browse(url)
      uri = URI(url)
      case uri.scheme
      when 'http'
        uri.scheme = 'https'
      when 'https'
        # Supported
      else
        raise NotImplementedError
      end

      Robro.browser = Browser.new options[:browser]
      Robro.browser.visit uri

      quit = false
      until quit
        byebug
      end
    end
  end
end
