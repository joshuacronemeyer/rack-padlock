require 'rainbow'
PADLOCK_LOG = 'tmp/padlock.log'

desc "Test for padlock"
task :padlock_test => [:padlock_clean, :test] do
  contents = File.open(PADLOCK_LOG, 'r') { |f| f.readlines }
  if File.size? PADLOCK_LOG
    puts "Padlock test failure: Insecure content is being loaded on the page.".foreground(:red)
    contents.each do |line|
      blocked_uri = line.match(/blocked-uri":"([^"]+)/)[1].foreground(:yellow)
      violated_directive = line.match(/violated-directive":"([^"]+)/)[1].foreground(:magenta)
      puts "Request for #{blocked_uri} has violated directive #{violated_directive}"
    end
    exit 1
  else
    puts "Padlock test success: page is secure.".foreground(:green)
  end
end

desc "Clean padlock logs"
task :padlock_clean do
  File.truncate('tmp/padlock.log', 0) if File.exist?(PADLOCK_LOG)
end