module Strava
  class LeaderboardEntry < Base
    # Class to represent Strava Activity
    # https://strava.github.io/api/v3/activities/
    attr_reader :rank

    def set_ivars
      @entries = {}
    end

    def athlete
      @athlete ||= Athlete.new({'id' => @athlete_id}, client: @client)
    end

    def activity
      @activity ||= Activity.new({'id' => @activity_id}, client: @client)
    end

    def effort
      @effort ||= SegmentEffort.new({'id' => @effort_id}, client: @client)
    end

    def update(data, **opts)
      @response = data

      @athlete_name     = data["athlete_name"]      # => "Jim Whimpey",
      @athlete_id       = data["athlete_id"]        # => 123529,
      @athlete_gender   = data["athlete_gender"]    # => "M",
      @average_hr       = data["average_hr"]        # => 190.5,
      @average_watts    = data["average_watts"]     # => 460.8,
      @distance         = data["distance"]          # => 2659.89,
      @elapsed_time     = data["elapsed_time"]      # => 360,
      @moving_time      = data["moving_time"]       # => 360,
      @start_date       = data["start_date"]        # => "2013-03-29T13:49:35Z",
      @start_date_local = data["start_date_local"]  # => "2013-03-29T06:49:35Z",
      @activity_id      = data["activity_id"]       # => 46320211,
      @effort_id        = data["effort_id"]         # => 801006623,
      @rank             = data["rank"]              # => 1,
      @athlete_profile  = data["athlete_profile"]   # => "http://pics.com/227615/large.jpg"

    end

  end
end

__END__

ca = Strava::Athlete.current_athlete;
