require 'test_helper'

module Workarea
  module Zipco
    class CheckoutTest < Workarea::TestCase
      setup :set_models

      def set_models
        @user = create_user
        @product = create_product(variants: [{ sku: 'SKU', regular: 5.to_m }])
        @order = create_order(zipco_order_id: "1234", items: [{ product_id: @product.id, sku: 'SKU' }])
        @checkout = Workarea::Checkout.new(@order, @user)
      end

      def test_complete_approved
        @checkout.payment.set_zipco(token: "1234")

        @checkout.steps.each do |step|
          step.any_instance.expects(:complete?).returns(true).at_least_once
        end
        Workarea::Checkout::ShippingOptions.any_instance.expects(:valid?).returns(true)

        zipco_checkout = Zipco::Checkout.new(@checkout, @user, { result: "approved", checkoutId: "1234" })
        complete = zipco_checkout.complete

        assert(complete)
      end

      def test_complete_referred
        @checkout.payment.set_zipco(token: "1234")

        @checkout.steps.each do |step|
          step.any_instance.expects(:complete?).returns(true).at_least_once
        end
        Workarea::Checkout::ShippingOptions.any_instance.expects(:valid?).returns(true)

        zipco_checkout = Zipco::Checkout.new(@checkout, @user, { result: "referred", checkoutId: "1234" })
        complete = zipco_checkout.complete
        assert(complete)
      end
    end
  end
end
