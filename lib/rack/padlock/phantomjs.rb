module Rack
  class Padlock
    class Phantomjs
      KILL_TIMEOUT = 20 # seconds
      attr_reader :pid, :binary
      
      def initialize(addresses, binary=nil)
        @binary = binary || 'phantomjs'
        @addresses = addresses
        @pid = nil
      end
      
      def command
        js_path = ::File.expand_path('../padlock.js', __FILE__)
        "#{@binary} --ignore-ssl-errors=yes #{js_path} #{@addresses.join(' ')}"
      end
        
      def start
        puts "Starting up phantomjs\n"
        Timeout.timeout(KILL_TIMEOUT) { system(command) }
      end
    end
  end
end