Workarea.configure do |config|
  config.order_status_calculators.insert(0, 'Workarea::Order::Status::ZipReferred')
  config.tender_types.append(:zipco)

  config.zipco = ActiveSupport::Configurable::Configuration.new
  config.zipco.api_version = "2017-03-01"
  config.zipco.api_timeout = 10
  config.zipco.open_timeout = 10

  config.zipco.marketing_assets_key = nil
  config.zipco.marketing_assets_env = Rails.env.production? ? "production" : "sandbox"

  config.zipco.show_tagline = true # toggles tagline on PDP and cart display
  config.zipco.allowed_countries = ["AU", "NZ"]
end
