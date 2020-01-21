module Workarea
  class Payment
    class Refund
      class Zipco
        include OperationImplementation
        include CreditCardOperation

        def complete!
          response = refund

          if response.success?
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.zipco.refund',
                amount: transaction.amount
              ),
              response.body
            )
          else
             transaction.response = ActiveMerchant::Billing::Response.new(
               false,
              I18n.t('workarea.zipco.refund_failure'),
              response.body.presence
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
            refund_response = response(request_id)
            if Workarea::Zipco::RETRY_ERROR_STATUSES.include? refund_response.status
              return response(request_id)
            end

            refund_response
          end

          def response(request_id)
             gateway.refund(charge_id, transaction.amount, request_id)
          end
      end
    end
  end
end
