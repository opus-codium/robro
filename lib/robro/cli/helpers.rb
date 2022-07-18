require 'tty-cursor'

require 'thor'

module Robro
  class CLI < Thor
    module Helpers
      def self.show_download_progress(changes, details)
        if changes['filename']
          puts "Downloading '#{details['filename']}' (size: #{details['size']})"
          puts "  progress: 0% rate: --- remaining time: ---"
        elsif changes['progress']
          print TTY::Cursor.prev_line
          print TTY::Cursor.clear_line
          puts "  progress: #{details['progress']} rate: #{details['rate']} remaining time: #{details['remaining_time']}"
        elsif changes['rate_average']
          puts "  rate average: #{details['rate_average']}"
        elsif changes['message']
          puts "Download message: #{changes['message']}"
        end
      end
    end
  end
end
