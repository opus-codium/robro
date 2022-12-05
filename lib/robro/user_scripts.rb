require 'active_support/inflector'

module Robro
  module UserScripts
    def self.all
      Dir.glob('userscripts/*.rb').map do |file|
        require File.expand_path(file)
        class_name = File.basename(file, '.rb').camelize
        const_get class_name
      end
    end

    def self.all_commands
      user_scripts = UserScripts.all.map(&:new)
      user_scripts.map(&:supported_url_commands).flatten.uniq
    end

    def self.find_for(uri:)
      user_scripts = UserScripts.all.map(&:new)
      user_scripts.find { |us| uri.host.start_with? *(us.supported_urls) }
    end

    def self.execute(command, uri, *args)
      us = find_for uri: uri

      raise "No user scripts found for URI: #{uri}" if us.nil?

      Robro.logger.info "Opening URL: #{uri}"
      Robro.browser.visit uri

      Robro.logger.info "User script: '#{us.class}' will process commnand '#{command}'"
      us.send(command, uri)
    end

    class Base
      def browser
        Robro.browser
      end

      def commands
        raise NotImplementedError
      end
    end
  end
end
