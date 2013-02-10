# rack-padlock

A toolkit for rack applications that ensures _ALL_ content on a page adheres to your [Content Security Policy][W3C CSP spec].  The browser padlock is pretty important for commercial web applications. Modern sites rely on so many third party services: analytics, video players, social media widgets.  With all these moving parts it's easy to end up with a broken padlock. Rack-Padlock will increase the visibility of padlock problems to your development team, and it's dead easy to use.

## Prerequisites

All you need to have a rack based application! (Rails, Sinatra, Camping, etc...)

## Setup

Add rack-padlock gem to your test group

```ruby
group :test do
  gem 'rack-padlock'
end
```

Add rack-padlock rake tasks to your app

```ruby
require 'rack/padlock'
load 'tasks/rack-padlock.rake'
```

Specify what url's you want to test somewhere in your Rakefile

```ruby
Rack::Padlock.padlock_uris = ["/secure", "/insecure"]
```

If your application isn't a Rails app, then you need to add an environment rake task to your Rakefile like this
```ruby
desc "setup application environment"
task :environment do
  require 'your rack application'
  Rack::Padlock.application = YourRackApplication
  Rack::Padlock.padlock_uris = ["/secure", "/insecure"]
end
```
## Running Tests

Once you've set things up simply run

```bash
rake padlock
```

This will run the padlock tests.  If any of your integration tests mix secure and insecure content, the padlock test will fail. ![alt text](http://dl.dropbox.com/u/80061077/Screenshots/c.png "Example of failing tests")

## Example rack application

Have a look at a simple sinatra application that demonstrates rack-padlock at https://github.com/joshuacronemeyer/rack-padlock-example-app

## How it works

Rack-Padlock starts your Rack app up with an SSL enabled webrick server.  It puts a custom middleware in front of your application that implements a CSP policy.  That policy requires the browser to notify us of any non SSL activity.  The custom middleware intercepts these notifications and logs them.  At the end of the run the rack-padlock test will either succeed or fail based on the presence of any policy violations.

## References

[W3C CSP spec]: http://www.w3.org/TR/CSP/