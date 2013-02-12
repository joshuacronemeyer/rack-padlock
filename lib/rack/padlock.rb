module Rack
  class Padlock
    @@application = nil
    @@padlock_uris = nil
    @@debug = false
    @@logfile = "tmp/padlock.log"
    
    POST_BODY  = 'rack.input'.freeze
    
    def initialize(app)
      @app = app
    end

    def call(env)
      return poke_response if poke?(env)
      return capture_violation(env) if csp_policy_violation?(env)
      status, headers, body = @app.call(env)
      headers.merge!(csp_headers(env))
      [status, headers, body]
    end
    
    def self.application=(app)
      @@application = app
    end
    
    def self.application
      @@application
    end
    
    def self.padlock_uris=(uri_list)
      @@padlock_uris = uri_list
    end
    
    def self.padlock_uris(base_uri)
      @@padlock_uris.map {|path| "#{base_uri}#{path}" } if @@padlock_uris
    end
    
    def self.debug=(flag)
      @@debug = flag
    end
    
    def self.debug?
      @@debug
    end
    
    def self.logfile=(log)
      @@logfile = log
    end
    
    def self.logfile
      @@logfile
    end
    private
  
    def capture_violation(env)
      violation = env[POST_BODY].read
      PadlockFile.write(Padlock.logfile, violation)
      [200, {"Content-Length"=>"0"}, []]
    end
  
    def poke_response
      [200, {}, []]
    end
    
    def csp_policy_violation?(env)
      env['PATH_INFO'] =~ /padlock_middleware\/report$/
    end
  
    def poke?(env)
      env['PATH_INFO'] =~ /padlock_middleware\/poke$/
    end
    
    def csp_headers(env)
      host = env["HTTP_HOST"]
      report_uri = "#{host}/padlock_middleware/report"
      csp_header_names = %w(Content-Security-Policy-Report-Only X-Content-Security-Policy-Report-Only X-WebKit-CSP-Report-Only)
      csp_headers = {}
      csp_header_names.each{|name| csp_headers[name] = "default-src https: data: 'unsafe-inline' 'unsafe-eval'; object-src 'none'; report-uri https://#{report_uri}"}
      csp_headers
    end
    
    class PadlockFile
      def self.write(file, violation)
        ::File.open(file, 'a+') { |file| file.puts violation.strip }
      end
    end
    
  end
end