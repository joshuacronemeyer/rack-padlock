require 'rainbow'
require 'rack/padlock'
require 'rack/padlock/server'
require 'rack/padlock/selenium'
require 'rack/padlock/string_util'

desc "Test for padlock"
task :padlock_test => [:environment] do
  rails_app = Rails.application if defined?(Rails)
  app = Rack::Padlock.application || rails_app
  puts "Padlock Test: checking #{app} for insecure content.".foreground(:green)
  server = Rack::Padlock::Server.new(app)
  server.boot
  uris = Rack::Padlock.padlock_uris(server.base_uri) || [server.base_uri]
  client = Rack::Padlock::Selenium.new(uris)
  client.start
end

desc "Test for padlock"
task :padlock => [:padlock_clean, :padlock_test, :padlock_check]

desc "Clean padlock logs"
task :padlock_check do
  contents = File.open(Rack::Padlock.logfile, 'r') { |f| f.readlines }
  if File.size? Rack::Padlock.logfile
    puts "Padlock test failure: Insecure content is being loaded on the page.".foreground(:red)
    contents.each do |line|
      what_match = line.match(/blocked-uri":"([^"]+)/)
      why_match = line.match(/violated-directive":"([^"]+)/)
      next unless what_match && why_match
      blocked_uri = what_match[1].foreground(:yellow)
      violated_directive = why_match[1].foreground(:magenta)
      util = Rack::Padlock::StringUtil.new
      puts "Request for #{util.elide(blocked_uri, 200)} has violated directive #{util.elide(violated_directive, 200)}"
    end
    exit 1
  else
    puts "Padlock test success: page is secure.".foreground(:green)
  end
end

desc "Clean padlock logs"
task :padlock_clean do
  File.truncate('tmp/padlock.log', 0) if File.exist?(Rack::Padlock.logfile)
end