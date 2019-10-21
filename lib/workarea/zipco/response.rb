module Workarea
  module Zipco
    class Response
      def initialize(response)
        @response = response
      end

      def success?
        @response.success?
      end

      def zipco_order_id
        body["id"]
      end

      def redirect_uri
        body["uri"]
      end

      def body
        @body ||= JSON.parse(@response.body)
      end
    end
  end
end
