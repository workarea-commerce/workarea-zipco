Workarea Zipco
================================================================================

Zip Payments plugin for the Workarea Commerce platform. Zip is presented as an alternative payment option to credit cards. Customers are taken off the site where they may log in to Zip Payments or create an account.

Zip payments offers the customer a line of credit account that can be used wherever Zip is offered as a payment option. Some credit applications will be placed into a "referred" state, where it will be approved or denied at a later date. Orders in a "referred" state have not had their payments collected yet. A Zip Payments representative will either approve or deny the order, a denied order is put into a canceled state. Approved orders will collect payment and be handled like a normal placed order.

Zip is only available to customers in Australia and New Zealand that are transacting in the Australian Dollar.

The following features are supported:

  1. Displaying the zip payment option in checkout.
  2. Authorization, capture, purchase and refund payment operations.
  3. Referred applications.
  4. Zip Payments landing page.
  5. Zip payment taglines on pdp and cart pages.



Implementation Notes
--------------------------------------------------------------------------------

This integration uses a full page redirect rather than the modal dialog box.

Zip Payments has a rigorous certification process that each merchant must complete. This plugin does not meet all of the branding and marketing requirements, as they are based on the design of the host application and is subject to change greatly between implementations.

A landing page is included in this integration located at:

    https://www.yourdomain.com/zipco_landing

This will display the Zip landing page via a javascript widget.

Configuration
--------------------------------------------------------------------------------

Add the following values to an initializer to configure Zip Payments:

    # Marketing key required to load the js widgets for landing page and taglines on PDP.
    config.zipco.marketing_assets_key = "your_key"

    # Environment for marketing assets. Possible values are "sandbox" and "production". Leave this blank to use "production" on production environments and "sandbox" for all other environments.
    config.zipco.marketing_assets_env = "sandbox"

    # Controls showing the zip payments tagline on the PDP and cart pages, requires the marketing assets key configuration to be present as well. Defaults to true.
    config.zipco.show_tagline = true


Secrets
--------------------------------------------------------------------------------

Add the zip payments secret key:

    zipco:
        secret_key: btZ9hDK2dBUbXipTVKjdsrNKuw6GXkN5MYSVq2i6Uqw=


Getting Started
--------------------------------------------------------------------------------

Add the gem to your application's Gemfile:

    # ...
    gem 'workarea-zipco'
    # ...

Update your application's bundle.

    cd path/to/application
    bundle

Workarea Platform Documentation
--------------------------------------------------------------------------------

See [http://developer.workarea.com](http://developer.workarea.com) for Workarea platform documentation.

Copyright & Licensing
--------------------------------------------------------------------------------

Copyright Workarea 2019. All rights reserved.

For licensing, contact sales@workarea.com.
