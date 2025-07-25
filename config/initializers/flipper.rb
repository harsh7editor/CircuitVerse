# frozen_string_literal: true

require "flipper/adapters/redis"

# default flipper configuration
default_flipper_features = {
  recaptcha: false,
  forum: false,
  project_comments: true,
  lms_integration: true,
  vuesim: false,
  block_registration: false,
  active_storage_s3: true,
  contests: false
}

Flipper.configure do |config|
  config.default do
    if Rails.env.test?
      adapter = Flipper::Adapters::Memory.new
    else
      client = Redis.new
      adapter = Flipper::Adapters::Redis.new(client)
    end

    # pass adapter to handy DSL instance
    Flipper.new(adapter)
  end
end

Flipper.enable(:contests) if Rails.env.test?

if ENV["DISABLE_FLIPPER"].blank? && !Rails.env.test?
  enabled_features = Flipper.features.map(&:name)
  default_flipper_features.each do |key, enabled|
    # If feature not set already then set to default
    unless enabled_features.include?(key.to_s)
      Flipper.enable(key) if enabled
      Flipper.disable(key) unless enabled
    end
  end
end

Flipper::UI.configure do |config|
  config.fun = false
end
