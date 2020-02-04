module Workarea
  class Payment
    module Authorize
      class Zipco
        include OperationImplementation
        include CreditCardOperation

        def complete!
          response = authorize
          if response.success?
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.zipco.authorize',
                amount: transaction.amount
              ),
              response.body
            )
          else
             transaction.response = ActiveMerchant::Billing::Response.new(
               false,
              I18n.t('workarea.zipco.authorize_failure'),
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
              capture: false
            }
          end

          def authorize
            request_id = SecureRandom.uuid
            auth_response = response(request_id)
            if Workarea::Zipco::RETRY_ERROR_STATUSES.include? auth_response.status
              return response(request_id)
            end

            auth_response
          end

          def response(request_id)
            gateway.authorize(transaction_attrs, request_id)
          end
      end
    end
  end
end
