require 'robro'
require 'robro/user_scripts'

require 'thor'
require 'json'

require 'active_support/inflector'

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
        UserScripts.all.each do |us_class|
          us = us_class.new
          next unless uri.host.start_with? *(us.supported_urls)

          unless us.nil?
            puts "Commands for this URL: #{us.supported_url_commands}"

            us.supported_url_commands.each do |command|
              define_singleton_method command do |*args|
                us.send(command, *args)
              end
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

    UserScripts.all.each do |us_class|
      us = us_class.new
      us.supported_url_commands.each do |command|
        desc "#{command} URL", command.to_s
        method_option :browser, :type => :string, :description => 'Supported values: firefox or chromium', :default => 'chrome'
        define_method command do |*args|
          url = args.shift
          raise Thor::Error, 'URL argument is missing' if url.nil?

          uri = validate_url(url)

          Robro.browser = Browser.new options[:browser]
          Robro.browser.visit uri

          puts JSON.pretty_generate(us.send(command, *args))
        end
      end
    end
  end
end
