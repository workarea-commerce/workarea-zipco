require 'test_helper'

module Workarea
  module Zipco
    class CheckoutTest < Workarea::TestCase
      setup :set_models

      def set_models
        @user = create_user
        @product = create_product(variants: [{ sku: 'SKU', regular: 5.to_m }])
        @order = create_order(zipco_order_id: "1234", items: [{ product_id: @product.id, sku: 'SKU' }])
        payment = create_payment(id: @order.id)
        @checkout = Workarea::Checkout.new(@order, @user)
        create_shipping_service(name: "test shipping")

        step = Workarea::Checkout::Steps::Addresses.new(@checkout)

        step.update(
          shipping_address: {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          },
          billing_address: {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          }
        )
      end

      def test_set_checkout_data
        Zipco::Setup.new(@checkout).set_checkout_data
        @checkout.order.reload

        order = @checkout.order
        payment = Workarea::Payment.find(order.id)

        assert(order.zipco_order_id.present?)
        assert(payment.zipco.present?)
      end

      def test_redirect_uri
        data = Zipco::Setup.new(@checkout).redirect_uri
        assert_equal(expected_redirect_uri, data)
      end

      private

        def expected_redirect_uri
          "https://account.sandbox.zipmoney.com.au/?co=co_P9GOgSVE9qMnL0VA6Jy8z6&m=aa7bd4b9-f270-4eba-94b7-a64e95f6b13f"
        end
    end
  end
end
