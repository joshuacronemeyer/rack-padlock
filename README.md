# rack-padlock

A toolkit for writing tests against rack applications that ensure all traffic on a page is secure.

## Prerequisites

1. You need to have a rack based application
2. The application must have a browser based integration test suite.  I recommend capybara.
3. Your integration tests must use HTTPS

## Setup

Add rack-padlock gem to your test group

```ruby
group :test do
  gem 'rack-padlock'
end
```

Add rack-padlock middleware to your app

```ruby
configure :test, :development do
  use Rack::Padlock
end
```

Add rack-padlock rake tasks to your app

```ruby
require 'rack/padlock'
load 'tasks/rack-padlock.rake'
```

## How it works

The middleware is setting the CSP policy so that your browser is going to start notifying your application when there is insecure content on the page.  rack-padlock is logging any policy violations.  At the end of the run the rack-padlock test will either succeed or fail based on the presence of any policy violations.

## Running Tests

Once you've set things up simply run

```bash
rake padlock_test
```

This will run your test suite.  If any of your integration tests mix secure and insecure content, the padlock test will fail.

## Example rack application

Have a look at the example application at https://github.com/joshuacronemeyer/rack-padlock-example-app

## References

1. https://dvcs.w3.org/hg/content-security-policy/raw-file/tip/csp-specification.dev.html