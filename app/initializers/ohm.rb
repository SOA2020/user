# frozen_string_literal: true

env = ENV['RACK_ENV'] || 'development'
redis_url = REDIS_URL = YAML.load_file('app/config/redis.yml')[env]
Ohm.redis = Redic.new(redis_url.to_s)
