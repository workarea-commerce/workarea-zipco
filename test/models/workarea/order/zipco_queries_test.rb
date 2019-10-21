require 'test_helper'

module Workarea
  module Zipco
    class ZipcoQueriesTest < Workarea::TestCase
      attr_reader :email, :user

      setup :setup_user

      def setup_user
        @email = 'bcrouse@workarea.com'
        @user = create_user(email: email)
      end

      def test_referred_orders_do_not_need_reminding
        referred_order = Workarea::Order.create!(email: email, checkout_started_at: 2.hours.ago, items: [{ product_id: '1', sku: 2 }], zipco_referred_at: Time.now)
        results = Workarea::Order.need_reminding.to_a

        refute_includes(results, referred_order)
      end

      def test_find_current_by_id_excludes_orders_under_review
        order = create_order(zipco_referred_at: Time.now)

        result = Workarea::Order.find_current(id: order.id)
        refute result.persisted?
      end

      def test_find_current_by_user_id_excludes_orders_under_review
        result = Workarea::Order.find_current(user_id: 'foo')
        refute result.persisted?
      end
    end
  end
end
