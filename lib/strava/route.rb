module Strava
  class Route < Base
    # Class to represent Strava Activity
    # https://strava.github.io/api/v3/activities/

    def set_ivars
      @streams = StreamSet.new
    end

    def update(data, **opts)
      @response = data
      @id                     = data["id"]
      @resource_state         = data['resource_state']
      self
    end

    def streams(**params)
      get_streams(**params) if @streams.empty?
      @streams
    end

    def get_details
      return self if detailed?
      res = client.get(path_base).to_h
      update(res)
      res
    end

    def get_streams(**params)
      res = client.get(path_streams, **params).to_a
      @streams.update(res)
    end

    def path_base
      "routes/#{id}"
    end

    def path_streams
      "#{path_base}/streams/"
    end
  end
end

__END__

ca = Strava::Athlete.current_athlete;
rlk = ca.friends.detect{|a| a.id == 3635502 }
r = rlk.routes.first
rlk.get_routes
r = rlk.routes.first
r.get_details
