module Strava
  class Segment < Base
    # Class to represent Strava Activity
    # https://strava.github.io/api/v3/activities/
    # Your code goes here...
    attr_reader :leaderboard

    def set_ivars
      @efforts  = {}
      @streams = StreamSet.new
    end
    def leaderboard
      @leaderboard ||= Leaderboard.new({'segment_id' => id}, client: @client)
    end

    def update(data, **opts)
      @response = data
      @id                     = data["id"]
      @resource_state         = data['resource_state']
    end

    def efforts(per_page: nil, page: nil, **params)
      # paginate('efforts', struct: Array, per_page: per_page, page: page)
      if page || per_page || !params.empty?
        get_efforts(per_page: per_page, page: page, **params)
      else
        get_efforts if @efforts.empty?
        @efforts.values
      end
    end

    # don't know if this really works or not. doesn't seem to work
    def star
      res = client.put(path_star, star: true).to_h
    end

    def unstar
      res = client.put(path_star, star: false).to_h
    end

    def streams(types = [:distance, :altitude, :latlng], **params)
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


    private def get_efforts(per_page: nil, page: nil)
      res = client.get(path_efforts, per_page: per_page, page: page).to_a
      parse_data(@efforts, res, klass: SegmentEffort, client: @client)
    end

    def path_base
      "segments/#{id}"
    end

    def path_efforts
      "#{path_base}/all_efforts"
    end

    def path_star
      "#{path_base}/starred"
    end

    def path_streams
      "#{path_base}/streams/"
    end

    def self.explorer(client, bounds = '37.821362,-122.505373,37.842038,-122.465977')
      res = client.get("segments/explore", bounds: bounds).to_h
      res['segments'].map { |hash| new(hash, client: client) }
    end

  end
end

__END__

ca = Strava::Athlete.current_athlete;
ca.segment_explorer
rlk = ca.friends.detect{|a| a.id == 3635502 };
segments = rlk.starred_segments;
seg = segments.first
seg.star
seg.unstar
seg.leaderboard
seg.leaderboard.standings
seg.efforts
