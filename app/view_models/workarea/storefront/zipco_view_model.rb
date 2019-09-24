module Workarea
  module Storefront
    class ZipcoViewModel < ApplicationViewModel
    def show?
      Zipco.config.allowed_countries.include?(order.billing_address.country.alpha2)
    end

    private

      def order
        @order ||= begin
          o = options[:order]
          Workarea::Storefront::OrderViewModel.new(o)
        end
      end
    end
  end
end
