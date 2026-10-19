require 'redis'

module Weby
  def self.redis
    return @redis if defined?(@redis)

    @redis = if ENV['REDIS_URL'].present?
               begin
                 Redis.new(url: ENV['REDIS_URL'])
               rescue StandardError => e
                 Rails.logger.warn("Weby.redis initialization error: #{e.message}")
                 nil
               end
             else
               nil
             end
  end
end
