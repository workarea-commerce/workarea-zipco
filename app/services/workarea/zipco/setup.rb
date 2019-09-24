module Workarea
  module Zipco
    class Setup
      attr_reader :checkout, :order

      # @param  ::Workarea::Checkout
      def initialize(checkout)
        @checkout = checkout
        @order = checkout.order
       end

      def create_order_response
        @create_order_response ||= Zipco.gateway.create_order(order_details)
      end

      def set_checkout_data
        payment = Workarea::Payment.find(order.id)

        payment.clear_credit_card

        payment.set_zipco(token: create_order_response.zipco_order_id)

        order.update_attributes!(zipco_order_id: create_order_response.zipco_order_id)
      end

      def redirect_uri
        create_order_response.redirect_uri
      end

      private

        def order_details
          Workarea::Zipco::Order.new(order).to_h
        end
    end
  end
end
