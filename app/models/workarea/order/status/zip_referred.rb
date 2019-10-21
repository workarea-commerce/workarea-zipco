module Workarea
  class Order
    module Status
      class ZipReferred
        include StatusCalculator::Status

        def in_status?
          !order.placed? && order.zipco_referred? && !order.canceled?
        end
      end
    end
  end
end
