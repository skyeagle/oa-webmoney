# oa-webmoney

## Usage with Devise

Original help page[https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview]

Gemfile

    gem 'oa-webmoney'

You should add wmid column:

    rails g migration add_wmid_to_user

and add code below to created migration:

    def self.up
      add_column :users, :wmid, :string, :limit => 12

      add_index :users, :wmid, :unique => true
    end

    def self.down
      remove_column :users, :wmid
    end

devise.rb

    config.omniauth :webmoney, :credentials => { :site_holder_wmid => 'your_site_wmid',
                        :app_rids => { 'localhost'   => 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
                                       'example.com' => 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' }}, :mode => Rails.env)

user.rb

    devise :omniauthable

    def self.find_for_webmoney_oauth(access_token, signed_in_resource=nil)
      data = access_token['extra']
      if user = User.find_by_wmid(data[:WmLogin_WMID])
        user
      else # Create an user with a stub password.
        User.create!(:email => "#{data[:WmLogin_WMID]}@wmkeeper.com", :password => Devise.friendly_token[0,20])
      end
    end

add link to authorize:

    <%= link_to "Sign in with Webmoney", user_omniauth_authorize_path(:webmoney) %>

routes.rb

    devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

app/controllers/users/omniauth_callbacks_controller.rb

    class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
      def webmoney
        # You need to implement the method below in your model
        @user = User.find_for_webmoney_oauth(env["omniauth.auth"], current_user)

        if @user.persisted?
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Webmoney"
          sign_in_and_redirect @user, :event => :authentication
        else
          session["devise.webmoney_data"] = env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    end

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
