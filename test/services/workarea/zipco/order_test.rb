require 'test_helper'

module Workarea
  module Zipco
    class OrderTest < Workarea::TestCase
      def test_to_h
        create_order_total_discount
        order = create_placed_order
        payment = Workarea::Payment.find(order.id)

        payment = Workarea::Payment.find(order.id)
        payment.profile.update_attributes!(store_credit: 1.00)
        payment.set_store_credit
        payment.tenders.first.amount = 1.to_m
        payment.save

        order.reload
        payment.reload

        order_hash = Workarea::Zipco::Order.new(order).to_h
        items = order_hash[:order][:items]
        assert_equal(4, items.size)

        assert_equal(10.00, order_hash[:order][:amount].to_f)

        discount_item = items.detect { |i| i[:type] == "discount" }
        assert_equal(-1.00, discount_item[:amount])

        zipco_order = order_hash[:order]
        assert_equal(order.id, zipco_order[:reference])
        assert_equal("USD", zipco_order[:currency])

        zipco_shipping = zipco_order[:shipping]
        assert(zipco_shipping.present?)
        assert(zipco_shipping[:address].present?)
      end

      private
        def create_order(overrides = {})
          attributes = {
            id: '1234',
            email: 'bcrouse-new@workarea.com',
            placed_at: Time.current
          }.merge(overrides)

          shipping_service = create_shipping_service
          product = create_product(variants: [{ sku: 'SKU', regular: 5.to_m }])

          order = Workarea::Order.new(attributes)
          order.add_item(product_id: product.id, sku: 'SKU', quantity: 2)

          checkout = Checkout.new(order)
          checkout.update(
            shipping_address: {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 S. 3rd St.',
              street_2: 'Second Floor',
              city: 'Philadelphia',
              region: 'PA',
              postal_code: '19106',
              country: 'US'
            },
            billing_address: {
              first_name: 'Bob',
              last_name: 'Clams',
              street: '12 N. 3rd St.',
              street_2: 'Second Floor',
              city: 'Wilmington',
              region: 'DE',
              postal_code: '18083',
              country: 'US'
            },
            shipping_service: shipping_service.name,
          )


          order
        end
    end
  end
end
