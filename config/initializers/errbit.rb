Airbrake.configure do |config|
  config.host = 'https://errbit.tsdv.net'
  config.project_id = 1 # required, but any positive integer works
  config.project_key = '92f1da135e8ff1d3a083c8904384aba9'

  # Uncomment for Rails apps
  config.environment = Rails.env
  config.ignore_environments = %w[development test]
end
