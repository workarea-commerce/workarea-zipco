module Workarea
  class Storefront::ZipcoController < Storefront::ApplicationController
    before_action :validate_checkout, only: :start

    def start
      zipco = Zipco::Setup.new(current_checkout)

      if zipco.create_order_response.success?
        zipco.set_checkout_data
        redirect_to zipco.redirect_uri
      else
        flash[:error] = t('workarea.storefront.zipco.payment_error')
        redirect_to(checkout_payment_path) && return
      end
    end

    def complete
      self.current_order = Order.where(zipco_order_id: params[:checkoutId]).first
      if !can_checkout?(params[:result])
        handle_negative_result
        redirect_to unfinished_checkout_destination
        return
      end

      # only check the inventory if immediate approval, approved referred orders
      # have already captured the inventory.
      check_inventory || return unless params[:result] == "approved" && current_order.zipco_referred?

      place_order_result = Zipco::Checkout.new(current_checkout, current_user, params).complete

      if place_order_result
        complete_place_order
      else
        incomplete_place_order
      end
    end

    private

      def can_checkout?(response_code)
        ["approved", "referred"].include?(response_code)
      end

      def complete_place_order
        Storefront::OrderMailer.confirmation(current_order.id).deliver_later unless current_order.zipco_referred?

        self.completed_order = current_order
        clear_current_order

        flash[:success] = t('workarea.storefront.flash_messages.order_placed')
        redirect_to finished_checkout_destination
      end

      def incomplete_place_order
        flash[:error] = t('workarea.storefront.zipco.payment_error')

        current_checkout.payment.clear_zipco!
        redirect_to checkout_payment_path
      end

      def finished_checkout_destination
        if current_admin.present? && current_admin.orders_access?
          admin.order_path(completed_order)
        else
          checkout_confirmation_path
        end
      end

      def unfinished_checkout_destination
        if self.current_order.zipco_referred? && params[:result] == "declined"
          cart_path
        else
          checkout_payment_path
        end
      end

      def handle_negative_result
        if params[:result] == "cancelled"
          flash[:success] = t('workarea.storefront.zipco.cancelled_message')
        elsif params[:result] == "declined"
          flash[:success] = t('workarea.storefront.zipco.declined_message')
        else
          flash[:error] = t('workarea.storefront.zipco.payment_error')
        end

        # if order was declined from an referred state than cancel the order,
        # otherwise simply clear out the zipco information.
        if params[:result] == "declined" && self.current_order.zipco_referred?
          CancelOrder.new(current_order, refund: false).perform
        else
          current_checkout.payment.clear_zipco!
          current_order.clear_zipco!
        end
      end
  end
end
