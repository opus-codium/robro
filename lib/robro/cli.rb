require 'robro'
require 'robro/user_scripts'

require 'thor'
require 'json'

module Robro
  class CLI < Thor
    desc 'browse URL', 'Start browser at URL, drop a shell'
    method_option :browser, :type => :string, :description => 'Supported values: firefox or chromium', :default => 'chrome'
    def browse(url)
      uri = validate_url(url)

      Robro.browser = Browser.new options[:browser]
      Robro.browser.visit uri

      quit = false
      until quit
        us = UserScripts.find_for uri: uri

        unless us.nil?
          puts "Commands for this URL: #{us.supported_url_commands}"

          us.supported_url_commands.each do |command|
            define_singleton_method command do |*args|
              us.send(command, *args)
            end
          end
        end

        byebug
      end
    end

    no_commands do
      def validate_url(url)
        uri = URI(url)

        case uri.scheme
        when 'http'
          uri.scheme = 'https'
        when 'https'
          # Supported
        else
          raise NotImplementedError
        end

        uri
      end
    end

    UserScripts.all_commands.each do |command|
      desc "#{command} URL", command.to_s
      method_option :browser, :type => :string, :description => 'Supported values: firefox or chromium', :default => 'firefox'
      define_method command do |*args|
        url = args.shift
        raise Thor::Error, 'URL argument is missing' if url.nil?

        uri = validate_url(url)

        Robro.browser = Browser.new options[:browser]

        result = UserScripts.execute command, uri

        puts JSON.pretty_generate(result)
      end
    end
  end
end
