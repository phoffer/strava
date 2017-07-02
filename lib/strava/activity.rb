module Strava
  # Class to represent Strava Activity
  # @see https://strava.github.io/api/v3/activities/ Strava Activity API Docs
  class Activity < Base
     ATTRIBUTES = [:external_id, :upload_id, :athlete, :name, :description, :distance, :moving_time, :elapsed_time, :total_elevation_gain, :elev_high, :elev_low, :type, :start_date, :start_date_local, :timezone, :start_latlng, :end_latlng, :location_city, :location_state, :location_country, :achievement_count, :kudos_count, :comment_count, :athlete_count, :photo_count, :total_photo_count, :map, :trainer, :commute, :manual, :private, :device_name, :embed_token, :flagged, :workout_type, :gear_id, :average_speed, :max_speed, :average_cadence, :average_temp, :average_watts, :max_watts, :weighted_average_watts, :kilojoules, :device_watts, :has_heartrate, :average_heartrate, :max_heartrate, :calories, :suffer_score, :has_kudoed, :splits_metric, :splits_standard, :best_efforts] # activity attributes, all have getter method
     attr_reader *ATTRIBUTES
     attr_reader :photos_info, :gear

    # Set up instance variables upon instantiation.
    #
    # @abstract
    # @return [void]
    private def set_ivars
      @kudos            = {}
      @comments         = {}
      @photos           = {}
      @laps             = {}
      @segment_efforts  = {}
      @related          = {}
      @streams          = StreamSet.new
    end

    # Updates activity with passed data attributes.
    # 
    # @param data [Hash] data hash containing activity data
    # @return [self]
    private def update(data, **opts)
      @response       = data
      @id             = data["id"]
      @resource_state = data['resource_state']
      @photos_info    = data['photos']
      @laps_info      = data['laps']
      @gear           = Gear.new(data['gear'], client: client) if data['gear']
      ATTRIBUTES.each do |attr|
        instance_variable_set("@#{attr}", data[attr.to_s])
      end

      parse_data(@segment_efforts, data["segment_efforts"], klass: SegmentEffort, client: @client) if data["segment_efforts"]
      self
    end

    def segment_efforts
      @segment_efforts.values
    end

    def kudos(per_page: nil, page: nil)
      if page || per_page
        get_kudos(per_page: per_page, page: page)
      else
        get_kudos if @kudos.empty?
        @kudos.values
      end
    end

    def comments(per_page: nil, page: nil)
      if page || per_page
        get_comments(per_page: per_page, page: page)
      else
        get_comments if @comments.empty?
        @comments.values
      end
    end

    def photos(per_page: nil, page: nil)
      if page || per_page
        get_photos(per_page: per_page, page: page)
      else
        get_photos if @photos.empty?
        @photos.values
      end
    end

    # Activities that were matched as “with this group”. The number equals activity.athlete_count-1. Pagination is supported.
    # @return [Strava::Activity] Related activities
    def related(per_page: nil, page: nil)
      if page || per_page
        get_related(per_page: per_page, page: page)
      else
        get_related if @related.empty?
        @related.values
      end
    end

    def streams(types = [:time, :distance, :latlng], **params)
      get_streams(types, **params) if @streams.empty?
      @streams
    end

    def zones
      get_zones unless @zones
      @zones
    end

    def laps
      get_laps if @laps.empty?
      @laps.values
    end

    def comment(message)
      res = client.post(path_comments, text: message).to_h
    end

    def kudo
      res = client.post(path_kudos).to_h
    end


    def get_details
      return self if detailed?
      res = client.get(path_base).to_h
      update(res)
    end
    def get_kudos(per_page: nil, page: nil)
      res = client.get(path_kudos, per_page: per_page, page: page).to_a
      parse_data(@kudos, res, klass: Athlete, client: @client)
    end
    def get_comments(per_page: nil, page: nil)
      res = client.get(path_comments, per_page: per_page, page: page).to_a
      parse_data(@comments, res, klass: Comment, client: @client)
    end
    def get_photos(per_page: nil, page: nil)
      res = client.get(path_photos, per_page: per_page, page: page).to_a
      parse_data(@photos, res, klass: Photo, client: @client)
    end
    def get_related(per_page: nil, page: nil)
      res = client.get(path_related, per_page: per_page, page: page).to_a
      parse_data(@related, res, klass: Activity, client: @client)
    end
    def get_streams(types = '', **params)
      res = client.get(path_streams + types.join(','), **params).to_a
      @streams.update(res)
    end
    def get_zones
      res = client.get(path_zones).to_a
      @zones = res
    end
    def get_laps
      res = client.get(path_laps).to_a
      parse_data(@laps, res, klass: Lap, client: @client)
    end


    def path_base
      "activities/#{id}"
    end
    def path_kudos
      "#{path_base}/kudos"
    end
    def path_comments
      "#{path_base}/comments"
    end
    def path_photos
      "#{path_base}/photos?photo_sources=true"
    end
    def path_related
      "#{path_base}/related"
    end
    def path_streams
      "#{path_base}/streams/"
    end
    def path_zones
      "#{path_base}/zones"
    end
    def path_laps
      "#{path_base}/laps"
    end
  end
end

activity_types = [
  'Ride',
  'Kitesurf',
  'Run',
  'NordicSki',
  'Swim',
  'RockClimbing',
  'Hike',
  'RollerSki',
  'Walk',
  'Rowing',
  'AlpineSki',
  'Snowboard',
  'BackcountrySki',
  'Snowshoe',
  'Canoeing',
  'StairStepper',
  'Crossfit',
  'StandUpPaddling',
  'EBikeRide',
  'Surfing',
  'Elliptical',
  'VirtualRide',
  'IceSkate',
  'WeightTraining',
  'InlineSkate',
  'Windsurf',
  'Kayaking',
  'Workout',
  'Yoga',
]

__END__

ca = Strava::Athlete.current_athlete;
act = ca.activities.first;
act.get_details
act.comments


ca = Strava::Athlete.current_athlete;
act = ca.activities.detect{|a| a.response['kudos_count'] > 0 }
act.get_kudos
ca = Strava::Athlete.current_athlete;
ca.activities;
ca.activities(page: 2);
ca.activities(page: 3);
ca.activities(page: 4);
act = ca.activities.detect{|a| a.response['comment_count'] > 0 && a.response['kudos_count'] > 0 }
act.kudos
act.photos
act.comments
act = ca.activities.detect{|a| a.response['comment_count'] > 0 }
act.get_comments

