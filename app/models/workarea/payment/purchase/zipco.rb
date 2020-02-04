module Workarea
  class Payment
    module Purchase
      class Zipco
        include OperationImplementation
        include CreditCardOperation

        def complete!
          response = purchase
          if response.success?
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.zipco.purchase',
                amount: transaction.amount
              ),
              response.body
            )
          else
             transaction.response = ActiveMerchant::Billing::Response.new(
               false,
              I18n.t('workarea.zipco.purchase_failure'),
              response.body.present? ? response.body : {}
            )
          end
        end

        def cancel!
          # No op - no cancel functionality available.
        end

        private

          def gateway
            Workarea::Zipco.gateway
          end

          def transaction_attrs
            {
              authority: {
                type: "checkout_id",
                value: tender.token
              },
              amount: transaction.amount.to_s,
              currency: transaction.amount.currency.iso_code,
              capture: true
            }
          end

          def purchase
            request_id = SecureRandom.uuid
            purchase_response = response(request_id)
            if Workarea::Zipco::RETRY_ERROR_STATUSES.include? purchase_response.status
              return response(request_id)
            end

            purchase_response
          end

          def response(request_id)
            gateway.purchase(transaction_attrs, request_id)
          end
      end
    end
  end
end
