module Workarea
  module Zipco
    class Checkout
      attr_reader :checkout, :order, :options, :user

      # @param  ::Workarea::Order
      def initialize(checkout, user, options = {})
        @checkout = checkout
        @user = user
        @options = options
        @order = Workarea::Order.where(zipco_order_id: zipco_order_id).first
      end

      def complete
        approved_referred_order = result == "approved" && order.zipco_referred?

        if result == "referred"
          order.set_zipco_referred_at!
        else
          order.update_attributes(zipco_referred_at: nil)
        end

        order.user_id = user.try(:id)

        Workarea::Pricing.perform(order, checkout.shipping)
        checkout.payment.adjust_tender_amounts(order.total_price)

        if order.zipco_referred?
          checkout.handle_zipco_referred
        elsif approved_referred_order
          checkout.handle_zipco_approved_referred
        else
          checkout.place_order
        end
      end

      private

      def result
        options[:result]
      end

      def zipco_order_id
        options[:checkoutId]
      end
    end
  end
end
