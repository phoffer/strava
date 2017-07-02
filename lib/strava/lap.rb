module Strava
  # Laps for an activity
  # 
  # Usage:
  # 
  #     ca = Strava::Athlete.current_athlete;
  #     activity = ca.activities.first;
  #     lap = activity.laps.first
  # 
  # @see https://strava.github.io/api/v3/activities/#laps Strava Docs - Activity Laps
  class Lap < Base

    def update(data, **opts)
      @response = data
      @id                   = data['id']
      @resource_state       = data["resource_state"]
      @name                 = data["name"]
      @activity             = data["activity"]
      @athlete              = data["athlete"]
      @elapsed_time         = data["elapsed_time"]
      @moving_time          = data["moving_time"]
      @start_date           = data["start_date"]
      @start_date_local     = data["start_date_local"]
      @distance             = data["distance"]
      @start_index          = data["start_index"]
      @end_index            = data["end_index"]
      @total_elevation_gain = data["total_elevation_gain"]
      @average_speed        = data["average_speed"]
      @max_speed            = data["max_speed"]
      @average_cadence      = data["average_cadence"]
      @average_heartrate    = data["average_heartrate"]
      @max_heartrate        = data["max_heartrate"]
      @lap_index            = data["lap_index"]
      @split                = data["split"]
      @pace_zone            = data["pace_zone"]
    end

  end
end
