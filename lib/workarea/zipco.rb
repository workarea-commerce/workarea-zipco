require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'

require 'workarea/zipco/engine'
require 'workarea/zipco/version'

require 'workarea/zipco/bogus_gateway'
require 'workarea/zipco/gateway'
require 'workarea/zipco/response'


require "faraday"

module Workarea
  module Zipco
    RETRY_ERROR_STATUSES = 500..599

    def self.credentials
      (Rails.application.secrets.zipco || {}).deep_symbolize_keys
    end

    def self.config
      Workarea.config.zipco
    end

    def self.secret_key
      return unless credentials.present?
      credentials[:secret_key]
    end

    def self.test?
      config[:test]
    end

    # Conditionally use the real gateway when secrets are present.
    # Otherwise, use the bogus gateway.
    #
    # @return [Zipco::Gateway]
    def self.gateway(options = {})
      if credentials.present?
        Zipco::Gateway.new(secret_key: secret_key, api_version: config.api_version)
      else
        Zipco::BogusGateway.new
      end
    end
  end
end
