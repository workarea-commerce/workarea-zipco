Workarea::Plugin.append_partials(
  'storefront.product_pricing_details',
  'workarea/storefront/zipco/zipco_tagline'
)

Workarea::Plugin.append_partials(
  'storefront.cart_checkout_actions',
  'workarea/storefront/zipco/zipco_tagline'
)

Workarea::Plugin.append_partials(
  'storefront.payment_method',
  'workarea/storefront/checkouts/zipco_payment'
)

Workarea::Plugin.append_partials(
  'storefront.checkout_confirmation_text',
  'workarea/storefront/orders/zipco_order_message'
)

Workarea::Plugin.append_stylesheets(
  "storefront.components",
  "workarea/storefront/zipco/components/zipco_icon"
)
