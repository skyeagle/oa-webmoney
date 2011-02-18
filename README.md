= oa-webmoney

=== Usage

You trigger an Webmoney request similar to HTTP authentication. From your app,
return a "401 Unauthorized" and a "WWW-Authenticate" header with the identifier you would like to validate.

On competition, the Webmoney response is automatically verified and assigned to
<tt>env["rack.webmoney.response"]</tt>.

=== Rails 3 Example

application.rb

  ...
  config.middleware.insert_before(Warden::Manager, Rack::Webmoney,
    :credentials => {:app_rids => { 'example.com' => 'your_site_rid' }, :site_holder_wmid => 'your_site_holder_wmid'},
    :mode => Rails.env)
  ...

=== Rack Example

  MyApp = lambda { |env|
    if resp = env["rack.webmoney.response"]
      case resp.status
      when :successful
        ...
      else
        ...
    else
      [401, {"WWW-Authenticate" => 'Webmoney"}, []]
    end
  }

  use Rack::Webmoney, :credentials => {:app_rids => { 'example.com' => 'your_site_rid' }, :site_holder_wmid => 'your_site_holder_wmid'}, :mode => "development_OR_test_FOR_TESTING"
  run MyApp

=== Sinatra Example

  # Session needs to be before Rack::OpenID
  use Rack::Session::Cookie

  require 'rack/webmoney'
  use Rack::Webmoney, :credentials => {:app_rids => { 'example.com' => 'your_site_rid' }, :site_holder_wmid => 'your_site_holder_wmid'}, :mode => "development_OR_test_FOR_TESTING"

  get '/login' do
    erb :login
  end

  post '/login' do
    if resp = request.env["rack.webmoney.response"]
      if resp.status == :successful
        "Welcome: #{resp.display_identifier}"
      else
        "#{resp.status}: #{resp.message}"
      end
    else
      headers 'WWW-Authenticate' => Rack::Webmoney.build_header({})
      throw :halt, [401, 'got webmoney?']
    end
  end

  use_in_file_templates!

  __END__

  @@ login
  <form action="/login" method="post">
    <p>
      <input style="display:none;" name="auth_provider" type="text" value="webmoney"/>
    </p>

    <p>
      <input name="commit" type="submit" value="Sign in" />
    </p>
  </form>

== Contributing to oa-webmoney
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2011 Anton. See LICENSE.txt for
further details.

