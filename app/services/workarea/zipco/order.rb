module Workarea
  module Zipco
    class Order
      module ProductUrl
        include Workarea::I18n::DefaultUrlOptions
        include Storefront::Engine.routes.url_helpers
        extend self
      end

      module ProductImageUrl
        include Workarea::ApplicationHelper
        include Workarea::I18n::DefaultUrlOptions
        include ActionView::Helpers::AssetUrlHelper
        include Core::Engine.routes.url_helpers
        extend self

        def mounted_core
          self
        end
      end

      attr_reader :order

      # @param  ::Workarea::Order
      def initialize(order)
        @order = Workarea::Storefront::OrderViewModel.new(order)
      end

      def to_h
        {
          shopper: zipco_shopper,
          order: zipco_order,
          config: zipco_config
        }
      end

      private
        def zipco_shopper
          {
            first_name: order.billing_address.first_name,
            last_name: order.billing_address.last_name,
            phone: order.billing_address.phone_number,
            email: order.email,
            billing_address: {
              line1: order.billing_address.street,
              line2: order.billing_address.street_2,
              city: order.billing_address.city,
              state: order.billing_address.region,
              postal_code: order.billing_address.postal_code,
              country: order.billing_address.country.alpha2
            }
          }
        end

        def zipco_order
          {
            reference: order.id,
            amount: order.order_balance.to_f,
            currency: currency_code,
            shipping: zip_shipping,
            items: items
          }
        end

        def currency_code
          @currency_code = order.total_price.currency.iso_code
        end

        def zip_shipping
          return unless shipping.present?
            {
              pickup: false, # integrate this with bopus?
              tracking: {
                carrier: shipping_service
              },
              address: {
                line1: order.shipping_address.street,
                city: order.shipping_address.city,
                state: order.shipping_address.region,
                postal_code: order.shipping_address.postal_code,
                country: order.shipping_address.country.alpha2
              }
            }
        end

        def shipping
          @shipping = Workarea::Shipping.find_by_order(order.id)
        end

        def shipping_service
          return unless shipping.present?
          shipping.shipping_service.name
        end

        def items
          items_array = order.items.map do |oi|

            {
              name: oi.product.name,
              amount: oi.original_unit_price.to_f,
              quantity: oi.quantity,
              type: "sku",
              reference: oi.id,
              #image_uri: ProductImageUrl.product_image_url(oi.image, :detail),
              item_uri: ProductUrl.product_url(id: oi.product.to_param, host: Workarea.config.host)
            }
          end

          # add taxes as item.
          items_array << {
            name: "Tax",
            amount: order.tax_total.to_f,
            quantity: 1,
            type: "tax",
            reference: "#{order.id}-tax",
          }

          # add shipping as item
          items_array << {
            name: "Shipping",
            amount: order.shipping_total.to_f,
            quantity: 1,
            type: "shipping",
            reference: "#{order.id}-shipping",
          }
          items_array + discount_items + advanced_payment_discount_item
        end

        def discount_items
          discounts = order.price_adjustments.select { |p| p.discount? }
          return [] unless discounts.present?

          discounts.map do |d|
            {
              name: "Discount",
              amount: d.amount.to_f,
              quantity: 1,
              type: "discount"
            }
          end
        end

        def advanced_payment_discount_item
          return [] if order.order_balance == order.total_price
          balance = order.total_price - order.order_balance

          [
            {
              name: "Other payment tenders",
              amount: (balance * -1).to_f,
              quantity: 1,
              type: "discount"
            }
          ]
        end

        def zipco_config
          {
            redirect_uri: confirm_url
          }
        end

        def confirm_url
          Storefront::Engine.routes.url_helpers.complete_zipco_url(host: Workarea.config.host)
        end
    end
  end
end
