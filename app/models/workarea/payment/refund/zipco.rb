module Workarea
  class Payment
    class Refund
      class Zipco
        include OperationImplementation
        include CreditCardOperation

        def complete!
          response = gateway.refund(charge_id, transaction.amount)

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
