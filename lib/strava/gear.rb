module Strava
  # Gear represents both shoes and bikes.
  # These are returned as part of the athlete summary.
  # 
  # @see https://strava.github.io/api/v3/gear/ Strava Gear API Docs
  class Gear < Base

    # Updates gear with passed data attributes.
    # 
    # @param data [Hash] data hash containing gear data
    # @return [self]
    def update(data, **opts)
      @response = data
      @id                     = data['id']
      @resource_state         = data['resource_state']
      self
    end

    # Retrieve full details for Gear object.
    # Sets all data attributes on self.
    # 
    # @return [Hash] raw API response
    def get_details
      return self if detailed?
      res = client.get(path_base).to_h
      update(res)
      res
    end

    # URL path for Gear object.
    # 
    # @return [String] URL path
    private def path_base
      "gear/#{id}"
    end
  end
end

__END__

ca = Strava::Athlete.current_athlete;
