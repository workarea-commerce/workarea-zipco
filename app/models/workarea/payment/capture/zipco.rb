module Workarea
  class Payment
    class Capture
      class Zipco
        include OperationImplementation
        include CreditCardOperation

        def complete!
          response = capture
          if response.success?
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.zipco.capture',
                amount: transaction.amount
              ),
              response.body
            )
          else
             transaction.response = ActiveMerchant::Billing::Response.new(
               false,
              I18n.t('workarea.zipco.capture_failure'),
              response.body.present? ? response.body : {}
            )
          end
        end

        def cancel!
          # No op - no cancel functionality available.
        end

        private

           def charge_id
            transaction.reference.response.params["id"]
          end

          def gateway
            Workarea::Zipco.gateway
          end

          def refund
            request_id = SecureRandom.uuid
            capture_response = response(request_id)
            if Workarea::Zipco::RETRY_ERROR_STATUSES.include? capture_response.status
              return response(request_id)
            end

            capture_response
          end

          def response(request_id)
            gateway.capture(charge_id, transaction.amount, request_id)
          end
      end
    end
  end
end
