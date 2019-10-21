require 'test_helper'

module Workarea
  module Storefront
    class ZipcoIntengrationTest < Workarea::IntegrationTest
      setup :set_order_data

      def set_order_data
        create_tax_category(
          name: 'Sales Tax',
          code: '001',
          rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
        )

        product = create_product(
          variants: [{ sku: 'SKU1', regular: 6.to_m, tax_code: '001' }]
        )

        create_shipping_service(
          carrier: 'UPS',
          name: 'Ground',
          service_code: '03',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        patch storefront.checkout_addresses_path,
          params: {
            email: 'bcrouse@workarea.com',
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '12 N. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '22 S. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          }
        patch storefront.checkout_shipping_path
      end

      def test_start_adds_a_token_to_payment
        get storefront.start_zipco_path

        payment = Payment.find(order.id)
        payment.reload

        assert(payment.zipco.present?)

        order.reload

        assert(order.zipco_order_id.present?)
      end

      def test_start_clears_credit_card
        payment = Payment.find(order.id)
        payment.set_credit_card({
          month: "01",
          year: Time.now.year + 1,
          number: 1,
          cvv: "123"
        })

        payment.reload

        get storefront.start_zipco_path

        payment.reload
        order.reload

        refute(payment.credit_card.present?)
        assert(payment.zipco.present?)
        assert(order.zipco_order_id.present?)
      end

      def test_cancel_removes_zipco
        payment = Payment.find(order.id)

        order.update_attributes(zipco_order_id: '1234')

        payment.set_zipco(token: '1234')

        assert(payment.zipco?)

        get storefront.complete_zipco_path(checkoutId: '1234', result: "cancelled")
        payment.reload
        order.reload

        refute(payment.zipco?)
        refute(order.zipco_order_id.present?)
      end

      def test_decline_removes_zipco
        payment = Payment.find(order.id)

        order.update_attributes(zipco_order_id: '1234')

        payment.set_zipco(token: '1234')

        assert(payment.zipco?)

        get storefront.complete_zipco_path(checkoutId: '1234', result: "declined")
        payment.reload
        order.reload

        refute(payment.zipco?)
        refute(order.zipco_order_id.present?)
      end

      def test_placing_order_from_zipco
        payment = Payment.find(order.id)

        get storefront.start_zipco_path

        params = { checkoutId: 'co_P9GOgSVE9qMnL0VA6Jy8z6', result: 'approved' }

        get storefront.complete_zipco_path(params)

        payment.reload
        order.reload


        assert(order.placed?)

        transactions = payment.tenders.first.transactions
        assert_equal(1, transactions.size)
        assert(transactions.first.success?)
        assert_equal('authorize', transactions.first.action)
      end

      def test_referred_then_approved_order_from_zipco
        payment = Payment.find(order.id)

        get storefront.start_zipco_path

        params = { checkoutId: 'co_P9GOgSVE9qMnL0VA6Jy8z6', result: 'referred' }

        get storefront.complete_zipco_path(params)

        payment.reload
        order.reload

        assert(order.zipco_order_id.present?)
        assert(:zipco_referred, order.status)
        refute(order.placed?)

        transactions = payment.tenders.first.transactions
        assert_equal(0, transactions.size)
        assert(order.zipco_referred?)
        assert_equal(:pending, payment.status)

        assert_redirected_to(storefront.checkout_confirmation_path)

        params = { checkoutId: 'co_P9GOgSVE9qMnL0VA6Jy8z6', result: 'approved' }

        get storefront.complete_zipco_path(params)

        payment.reload
        order.reload
        transactions = payment.tenders.first.transactions

        assert_equal(1, transactions.size)
        assert(order.zipco_order_id.present?)
        assert(order.placed?)
        assert(:authorized, payment.status)
        refute(order.zipco_referred?)
        assert_redirected_to(storefront.checkout_confirmation_path)
      end

      def test_referred_then_cancelled_order_from_zipco
        payment = Payment.find(order.id)

        get storefront.start_zipco_path

        params = { checkoutId: 'co_P9GOgSVE9qMnL0VA6Jy8z6', result: 'referred' }

        get storefront.complete_zipco_path(params)

        order.reload
        payment.reload

        assert(order.zipco_order_id.present?)
        refute(order.placed?)

        assert(order.zipco_referred?)
        assert_equal(:pending, payment.status)

        params = { checkoutId: 'co_P9GOgSVE9qMnL0VA6Jy8z6', result: 'declined' }

        get storefront.complete_zipco_path(params)

        payment.reload
        order.reload

        assert_equal(:canceled, order.status)

        transactions = payment.tenders.first.transactions
        assert(:pending, payment.status)
        assert_equal(0, transactions.size)
        assert_redirected_to(storefront.cart_path)
      end

      def test_failed_zipco_capture
        payment = Payment.find(order.id)

        payment.set_zipco(token: 'error_token')

        params = { token: 'error_token', status: 'SUCCESS' }

        get storefront.complete_zipco_path(params)

        payment.reload
        order.reload

        refute(order.placed?)
      end

      private

      def order
         @order ||= Order.first
       end

      def product
        @product ||= create_product(
          variants: [{ sku: 'SKU1', regular: 6.to_m, tax_code: '001' }]
        )
      end
    end
  end
end
