module Workarea
  class Payment
    class Capture
      class Zipco
        include OperationImplementation
        include CreditCardOperation

        def complete!
          response = gateway.capture(charge_id, transaction.amount)
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
              response.body
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
      end
    end
  end
end
