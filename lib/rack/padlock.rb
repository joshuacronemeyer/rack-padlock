module Rack
  class Padlock
    POST_BODY  = 'rack.input'.freeze
    
    def initialize(app, options={})
      default_options = {
        :log_file => "tmp/padlock.log"
      }
      @app = app
      @options = default_options.merge(options)
    end

    def call(env)
      return capture_violation(env) if csp_policy_violation?(env)
      status, headers, body = @app.call(env)
      headers.merge!(csp_headers(env))
      [status, headers, body]
    end
  
    private
  
    def capture_violation(env)
      violation = env[POST_BODY].read
      PadlockFile.write(violation)
      [200, {}, []]
    end
  
    def csp_policy_violation?(env)
      env['PATH_INFO'] =~ /padlock_middleware\/report$/
    end
  
    def csp_headers(env)
      host = env["HTTP_HOST"]
      report_uri = "#{host}/padlock_middleware/report"
      csp_header_names = %w(Content-Security-Policy-Report-Only X-Content-Security-Policy-Report-Only X-WebKit-CSP-Report-Only)
      csp_headers = {}
      csp_header_names.each{|name| csp_headers[name] = "default-src https: 'unsafe-inline' 'unsafe-eval'; report-uri http://#{report_uri}"}
      csp_headers
    end
    
    class PadlockFile
      def self.write(violation)
        ::File.open(@options[:log_file], 'a') { |file| file.write(violation) }
      end
    end
    
  end
end