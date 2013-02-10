require 'timeout'
require 'rack'
module Rack
  class Padlock
    
    class Server
      PORT = 9988
      attr_reader :app

      def initialize(app)
        @app = app
        @middleware = Rack::Padlock.new(@app)
        @server_thread = nil
      end

      def boot
        @server_thread = Thread.new do
          webserver = Rack::Padlock::Webrick.run(@middleware, PORT)
        end

        Timeout.timeout(60) { @server_thread.join(0.1) until responsive? }
      rescue Timeout::Error
        raise "Rack application timed out during boot"
      else
        self
      end
      
      def responsive?
        return false if @server_thread && @server_thread.join(0)

        require "net/https"
        require 'uri'
        uri = URI.parse("#{base_uri}/padlock_middleware/poke")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        return response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
      rescue Errno::ECONNREFUSED, Errno::EBADF
        return false
      end

      def base_uri
        "https://localhost:#{PORT}"
      end
    end
    
    class Webrick
      def self.run(app, port)
        puts "Starting up SSL webrick\n"
        require 'rack/handler/webrick'
        require 'webrick/https'
        require 'openssl'
        webrick_options = {
          :Port => (port), 
            :AccessLog => [],
            :Logger => WEBrick::Log::new(nil, 0),
            :SSLEnable => true,
            :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
            :SSLPrivateKey => OpenSSL::PKey::RSA.new(KEY),
            :SSLCertificate => OpenSSL::X509::Certificate.new(CRT),
            :SSLCertName => [["CN", WEBrick::Utils::getservername]]
        }
        webrick_options.merge({:Logger => WEBrick::Log::new($stdout, WEBrick::Log::DEBUG)}) if Rack::Padlock.debug?
        Rack::Handler::WEBrick.run(app, webrick_options)
      end
      
      KEY=<<EOF
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDayqjBWENExonuc2RPbegDb7O2r5vw+iVl0MBF9sQAmuu3vuoN
UCeNgF2CFvMpFQFsQ8hm+qnnDQFU66+lEXfR5bfRd8whOIS7ysD5nDzr8wKhqX9s
964zhVInvfEinmggyxz6BdkWTXsMblS1Z0JjsomFrhQkIkw82r5t7Hc4iQIDAQAB
AoGBALAo4i0iQq86Z84s7IQjit5RbtJVnGovDjNnG5h5ciDGm6nLNqnXcrE0vJVE
oy3dstKX1OBNTMUyrHLSfQ6b/OrvKw6dg7ndyFK+XO4zLFB5B0sCE5Bp05Ycjlj1
8IAuu9k2e3ozDjf1tNpD80OTa8S3y4+4yxeN5QYbAd2eh+7tAkEA8WbVz8Cjaf9w
y53k5L9Rv7GP54CI2f7LAsla6TUqQsgjvKTOqalGm4O/7N62nj/JAyWWQl72d4GQ
xL2ZZyhCxwJBAOgFy5b0yNP/QywzEtpwP3JBrOIdYqV/oXxE0rCzJkWC94xm2J1p
0198fNjgueAy4YnuMjR6nTGjBVCdU82fWi8CQB93t0ForCSiHrL8Nx02b1Kcs9SK
pcw88XvAgbBKtOKVskrh9Oqa3VBiYT9gXM/OIsbdPHQUau5zHkr3KCsRTXsCQQCT
bStBjeQVoDpkWUd/eJc32DcrrZRCqGhJd8mP8SU+QctdcPPugZGHOKhzfcddh7b7
V1ibM9Wx9m2oHW9kVf6NAkA1q90FzKwrpFmyzwKCe7wWhPd3GlN4qXvwdEW4kk1b
KTjyjrIXRt5UObL+ywhdkES8h2+rUFw5hXfyzIpafjyZ
-----END RSA PRIVATE KEY-----
EOF
      CRT=<<EOF
-----BEGIN CERTIFICATE-----
MIIB8TCCAVoCCQCD/Pvld7jzMDANBgkqhkiG9w0BAQUFADA8MQswCQYDVQQGEwJV
UzELMAkGA1UECAwCQ0ExCzAJBgNVBAcMAlNGMRMwEQYDVQQKDApDb2xsZWdlc2V0
MCAXDTEzMDIwNzE5MzM1M1oYDzMwMTIwNjEwMTkzMzUzWjA8MQswCQYDVQQGEwJV
UzELMAkGA1UECAwCQ0ExCzAJBgNVBAcMAlNGMRMwEQYDVQQKDApDb2xsZWdlc2V0
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDayqjBWENExonuc2RPbegDb7O2
r5vw+iVl0MBF9sQAmuu3vuoNUCeNgF2CFvMpFQFsQ8hm+qnnDQFU66+lEXfR5bfR
d8whOIS7ysD5nDzr8wKhqX9s964zhVInvfEinmggyxz6BdkWTXsMblS1Z0JjsomF
rhQkIkw82r5t7Hc4iQIDAQABMA0GCSqGSIb3DQEBBQUAA4GBACbe+qTXarpzRtRx
+v3AQhN/nMMKHvDwIhfiDlJva0DcRvWi9FDyyQVO8NA5YgcfMPI0iN1opEfOSrfG
mtyWupIL5lpn4EzW9r/0jOhjwA2NDN/BVYiFe4ovsPvJCOWti1bs7xMz7bSaFiNr
fi5nkNjLgLQmZHUj9/soMSfRGbP1
-----END CERTIFICATE-----
EOF
    end
  end
end