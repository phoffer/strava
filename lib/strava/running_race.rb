module Strava
  class RunningRace < Base

    def update(data, **opts)
      @response       = data
      @id             = data['id']
      @resource_state = data['resource_state']

      @name                   = data["name"]
      @start_date_local       = data["start_date_local"]
      @distance               = data["distance"]
      @city                   = data["city"]
      @state                  = data["state"]
      @country                = data["country"]
      @measurement_preference = data["measurement_preference"]
      @running_race_type      = data["running_race_type"]
      @url                    = data["url"]
      @resource_state         = data["resource_state"]
      @status                 = data["status"]
      @website_url            = data["website_url"]
      @route_ids              = data["route_ids"]

      self
    end

    def get_details
      return self if detailed?
      res = client.get(path_base).to_h
      update(res)
      res
    end
    def path_base
      "running_races/#{id}"
    end

    def self.list_races(client, year = Time.now.year)
      res = client.get("running_races", year: year).to_a
      res.map { |hash| new(hash, client: client) }
    end

  end
end


__END__

ca = Strava::Athlete.current_athlete;
races = ca.list_races;
rr = races.first;
rr.get_details
