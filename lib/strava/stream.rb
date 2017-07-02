module Strava
  class Stream
    # Class to represent Strava Stream
    # https://strava.github.io/api/v3/activities/

    attr_reader :type, :data

    def initialize(data)
      # @response = data
      @id             = data["id"]
      
      @type           = data["type"]          # => "latlng",
      @data           = data["data"]          # => [...],
      @series_type    = data["series_type"]   # => "distance",
      @original_size  = data["original_size"] # => 512,
      @resolution     = data["resolution"]    # => "low"

      self
    end

    def size
      @data.size
    end
    def [](i)
      @data[i]
    end

  end
end

__END__

ca = Strava::Athlete.current_athlete;
