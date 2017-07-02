module Strava
  # Provides data on Strava API limits and usage.
  #
  # Usage:
  # 
  #     ca = Strava::Athlete.current_athlete
  #     usage = ca.client.usage
  #     usage.recent_usage  # => 254
  #     usage.daily_usage   # => 12536
  #     usage.recent_pct    # => 0.423
  #     usage.daily_pct     # => 0.417
  # 
  # @see https://strava.github.io/api/#rate-limiting Strava Docs - Rate Limiting
  class Usage
    attr_reader :recent_limit, :daily_limit, :recent_usage, :daily_usage

    def initialize(limit_str, usage_str)
      @recent_limit, @daily_limit = limit_str.to_s.split(',').map(&:to_i)
      @recent_usage, @daily_usage = usage_str.to_s.split(',').map(&:to_i)
    end

    # Percentage of recent limit used.
    # 
    # @return [Float] Between 0.0 and 1.0
    def recent_pct
      @recent_usage.fdiv(@recent_limit)
    end

    # Percentage of daily limit used.
    # 
    # @return [Float] Between 0.0 and 1.0
    def daily_pct
      @daily_usage.fdiv(@daily_limit)
    end

  end
end

