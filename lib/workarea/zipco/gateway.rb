module Workarea
  module Zipco
    class Gateway
      attr_reader :options

      def initialize(options = {})
        requires!(options, :secret_key, :api_version)
        @options = options
      end

      def create_order(order)
        response = connection.post do |req|
          req.url "merchant/v1/checkouts"
          req.body = order.to_json
        end

        Zipco::Response.new(response)
      end

      def authorize(attrs)
        response = connection.post do |req|
          req.url "merchant/v1/charges"
          req.body = attrs.to_json
        end

        Zipco::Response.new(response)
      end
      alias :purchase :authorize

      def capture(charge_id, amount)
        body = {
          amount: amount.to_f
        }

        response = connection.post do |req|
          req.url "merchant/v1/charges/#{charge_id}/capture"
          req.body = body.to_json
        end

        Zipco::Response.new(response)
      end

      def refund(charge_id, amount)
        reason = "Web Refund"
        body = {
          charge_id: charge_id,
          reason: reason,
          amount: amount.to_f
        }

        response = connection.post do |req|
          req.url "merchant/v1/refunds"
          req.body = body.to_json
        end
        Zipco::Response.new(response)
      end

      private

        def connection
          headers = {
            "Content-Type"  => "application/json",
            "Accept"        => "application/json",
            "Authorization" => "Bearer #{secret_key}",
            "zip-version"   => api_version
          }

          request_timeouts = {
            timeout: Workarea.config.zipco[:api_timeout],
            open_timeout: Workarea.config.zipco[:open_timeout]
          }

          Faraday.new(url: rest_endpoint, headers: headers, request: request_timeouts)
        end

        def api_version
          options[:api_version] || "2017-03-01"
        end

        def secret_key
          options[:secret_key]
        end

        def test?
          (options.has_key?(:test) ? options[:test] : true)
        end

        def rest_endpoint
          if test?
            "https://api.sandbox.zipmoney.com.au"
          else
            "https://api.zipmoney.com.au"
          end
        end

        def requires!(hash, *params)
          params.each do |param|
            if param.is_a?(Array)
              raise ArgumentError.new("Missing required parameter: #{param.first}") unless hash.has_key?(param.first)

              valid_options = param[1..-1]
              raise ArgumentError.new("Parameter: #{param.first} must be one of #{valid_options.to_sentence(words_connector: 'or')}") unless valid_options.include?(hash[param.first])
            else
              raise ArgumentError.new("Missing required parameter: #{param}") unless hash.has_key?(param)
            end
          end
        end
    end
  end
end
