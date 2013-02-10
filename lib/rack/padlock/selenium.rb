require "selenium-webdriver"
module Rack
  class Padlock
    class Selenium
      def initialize(addresses)
        @addresses = addresses
      end
      
      def start
        puts "Starting up selenium webdriver\n"
        @driver = ::Selenium::WebDriver.for :firefox
        @driver.manage.timeouts.implicit_wait = 30
        @addresses.each{|address| @driver.get(address)}
        @driver.quit
      end
    end
  end
end