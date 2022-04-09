module Robro
  module UserScripts
    def self.all
      Dir.glob('userscripts/*.rb').map do |file|
        require File.expand_path(file)
        class_name = File.basename(file, '.rb').camelize
        const_get class_name
      end
    end

    class Base
      def commands
        raise NotImplementedError
      end
    end
  end
end
