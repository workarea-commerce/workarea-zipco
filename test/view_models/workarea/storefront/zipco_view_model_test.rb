require 'test_helper'

module Workarea
  module Storefront
    class ZipcoViewModelTest < TestCase
      def order
        @order ||= create_order(email: 'test@workarea.com')
      end

      def payment
        @payment ||=
          create_payment(id: order.id).tap do |payment|
            payment.set_address(
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 S. 3rd St.',
              city: 'Philadelphia',
              region: 'PA',
              postal_code: '19106',
              country: 'US',
              phone_number: '2159251800'
            )

            payment.set_credit_card(
              number: '1',
              month: 1,
              year: Time.current.year + 1,
              cvv: '999',
              amount: 5.to_m
            )
          end
      end

      def test_show?
        wa_payment = payment
        view_model = Workarea::Storefront::ZipcoViewModel.new(nil, { order: order })
        refute(view_model.show?)

        wa_payment.set_address(
          first_name: 'Paul',
          last_name: 'Hogan',
          street: '22 S. 3rd St.',
          city: 'Queensland',
          region: 'NT',
          postal_code: '19106',
          country: 'AU',
          phone_number: '2159251800'
        )

        view_model = Workarea::Storefront::ZipcoViewModel.new(nil, { order: order })
        assert(view_model.show?)
      end
    end
  end
end
