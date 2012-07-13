require 'omniauth'
require 'webmoney'

module OmniAuth
  module Strategies
    class Webmoney
      include OmniAuth::Strategy
      class WmLib
        include ::Webmoney
      end

      ERROR_MESSAGES = {
        # -3 unknown response
        :server_not_available => "Unknown response",
        # -2 raised network error
        :server_not_available => "Sorry, the Webmoney Login server is not available",
        # -1
        :internal_error       => "Webmoney Login server internal error",
        # 1
        :invalid_arguments    => "Invalid arguments",
        # 2
        :ticket_invalid       => "Sorry, invalid authorization ticket",
        # 3
        :ticket_expired       => "Sorry, authorization ticket expired",
        # 4
        :user_not_found       => "Sorry, user not found",
        # 5
        :holder_not_found     => "The holder of a site not found",
        # 6
        :website_not_found    => "Website Not Found",
        # 7
        :url_not_found        => "This url is not found, or does not belong to the site",
        # 8
        :settings_not_found   => "Security Settings for the site could not be found",
        # 9
        :invalid_password     => "Access service is not authorized. Invalid password.",
        # 10
        :not_trusted          => "Attempting to gain access to the site, which does not accept you as a trustee",
        # 11
        :pwd_access_blocked   => "Password access to the service blocked",
        # 12
        :user_blocked         => "The user is temporarily blocked. Probably made the selection Ticket",
        # 201
        :ip_differs           => "Ip address in the request differs from the address, which was an authorized user",

        :canceled             => "Authorization was canceled by user"
      }

      option :credentials
      option :env, :production
      option :wm_instance
      option :fields, [:WmLogin_Ticket, :WmLogin_UrlID, :WmLogin_Expire, :WmLogin_AuthType,
                       :WmLogin_LastAccess, :WmLogin_Created, :WmLogin_WMID, :WmLogin_UserAddress]

      def request_phase
        r = Rack::Response.new
        r.redirect "https://login.wmtransfer.com/GateKeeper.aspx?RID=#{options[:credentials][:app_rids][request.host]}"
        r.finish
      end

      def callback_phase
        if request.params["WmLogin_KeeperRetStr"] == "Canceled"
          return fail!(:canceled, OmniAuth::Error.new(ERROR_MESSAGES[:canceled]))
        end

        # work around for local development
        ip_to_check = [:development, :test].include?(options[:env].to_sym) ? extra[:WmLogin_UserAddress] : request.ip

        check_req_params = extra.merge({:remote_ip => ip_to_check})

        options[:wm_instance] ||= WmLib.new(:wmid => options[:credentials][:site_holder_wmid])

        begin
          response = options[:wm_instance].request(:login, check_req_params)[:retval]
        rescue Errno::ECONNRESET, Errno::ECONNREFUSED, Timeout::Error => e
          response = -2
        rescue ::Webmoney::ResultError => e
          response = options[:wm_instance].error
        end

        status = case response
        when 0  then :successful
        when -3  then :unknown_response
        when -2  then :server_not_available
        when -1  then :internal_error
        when 1   then :invalid_arguments
        when 2   then :ticket_invalid
        when 3   then :ticket_expired
        when 4   then :user_not_found
        when 5   then :holder_not_found
        when 6   then :website_not_found
        when 7   then :url_not_found
        when 8   then :settings_not_found
        when 9   then :invalid_password
        when 10  then :not_trusted
        when 11  then :pwd_access_blocked
        when 12  then :user_blocked
        when 201 then :ip_differs
        end

        return fail!(status, OmniAuth::Error.new(ERROR_MESSAGES[status])) unless status == :successful

        super
      end

      def uid
        extra[:WmLogin_WMID]
      end

      def extra
        options.fields.inject({}) do |hash, field|
          hash[field] = request.params[field.to_s]
          hash
        end
      end
    end
  end
end
