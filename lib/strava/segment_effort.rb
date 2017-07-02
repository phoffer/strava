module Strava
  class SegmentEffort < Base
    # Class to represent Strava Activity
    # https://strava.github.io/api/v3/activities/
    attr_reader :segment

    def set_ivars
      @streams = StreamSet.new
    end

    def update(data, **opts)
      @response = data
      @id             = data["id"]
      @resource_state = data['resource_state']
      @segment        = Segment.new(data['segment'], client: @client) if data['segment']
    end

    def streams(types = [:time, :distance, :latlng], **params)
      get_streams(types, **params) if @streams.empty?
      @streams
    end

    def get_details
      return self if detailed?
      res = client.get(path_base).to_h
      update(res)
      res
    end

    def get_streams(types = '', **params)
      res = client.get(path_streams + types.join(','), **params).to_a
      @streams.update(res)
    end
    def path_base
      "segment_efforts/#{id}"
    end
    def path_streams
      "#{path_base}/streams/"
    end
  end
end

__END__

ca = Strava::Athlete.current_athlete;
