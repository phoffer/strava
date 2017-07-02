module Strava
  # Strava Athlete class. For the most part, API interaction deals with the currently authenticated athlete.
  # 
  # There are mixins available to provide convenient ways to instantiate an athlete, see {Strava.model} for more information.
  # 
  # Usage:
  # 
  #     ca = Strava::Athlete.current_athlete(access_token)
  #     ca.firstname    # => 'John'
  #     ca.lastname     # => 'Applestrava'
  #     ca.profile      # => 'http://pics.com/227615/large.jpg'
  # 
  # @see https://strava.github.io/api/v3/athlete/ Strava Docs - Athlete
  class Athlete < Base

    attr_reader :firstname, :lastname, :profile_medium, :profile, :city, :state, :country, :sex, :friend, :follower, :premium, :created_at, :updated_at, :follower_count, :friend_count, :mutual_friend_count, :athlete_type, :date_preference, :measurement_preference, :email, :ftp, :weight, :bikes, :shoes

    # Set up instance variables upon instantiation.
    #
    # @abstract
    # @return [void]
    private def set_ivars
      @activities         = {}
      @friends_activities = {}
      @routes             = {}
      @connections        = {}
      @both_following     = {}
      @koms               = {}
      @gear               = {}
      @clubs              = {}
      @heatmaps           = {}
      @starred_segments   = {}

      @friends            = []
      @followers          = []
    end

    def initialize(data, client: nil, token: nil, **opts)
      @current  = !!opts[:current]
      super
    end

    # Update an existing athlete. 
    # Used by other methods in the gem.
    # Should not be used directly.
    # 
    # @private
    # @param data [Hash] data to update the athlete with
    # @return [self]
    def update(data, **opts)
      @id                     = data["id"]
      @username               = data["username"]
      @resource_state         = data["resource_state"]
      @firstname              = data["firstname"]
      @lastname               = data["lastname"]
      @city                   = data["city"]
      @state                  = data["state"]
      @country                = data["country"]
      @sex                    = data["sex"]
      @premium                = data["premium"]
      @created_at             = data["created_at"]
      @updated_at             = data["updated_at"]
      @badge_type_id          = data["badge_type_id"]
      @profile_medium         = data["profile_medium"]
      @profile                = data["profile"]
      @friend                 = data["friend"]
      @follower               = data["follower"]
      @follower_count         = data["follower_count"]
      @friend_count           = data["friend_count"]
      @mutual_friend_count    = data["mutual_friend_count"]
      @athlete_type           = data["athlete_type"]
      @date_preference        = data["date_preference"]
      @measurement_preference = data["measurement_preference"]
      @email                  = data["email"]
      @ftp                    = data["ftp"]
      @weight                 = data["weight"]
      @bikes                  = parse_data(@gear, data['bikes'], klass: Gear, client: @client)
      @shoes                  = parse_data(@gear, data['shoes'], klass: Gear, client: @client)

      parse_data(@clubs, data['clubs'], klass: Club, client: @client)

      self
    end

    # Whether this is the currently authenticated athlete.
    # Strava's API has reduced access for athletes other than the currently authenticated one.
    # 
    # @return [Boolean]
    def current?
      @current
    end

    ## Non athlete specific methods

    # Retrieve running races.
    # This is not related to the current athlete, but does require an access token. 
    # 
    # Also available via {RunningRace.list_races}
    # 
    # @param year [Integer] Year to retrieve races for
    def list_races(year = Time.now.year)
      client.list_races(year)
    end

    # Segment Explorer will find popular segments within a given area.
    # Requires a comma separated list of bounding box corners.
    # 
    # Also available via {Segment.explorer}
    # 
    # @param bounds [String] ‘sw.lat,sw.lng,ne.lat,ne.lng’ or alternatively, ‘south,west,north,east’
    def segment_explorer(bounds = '37.821362,-122.505373,37.842038,-122.465977')
      client.segment_explorer(bounds)
    end

    # Gear list. Includes shoes and bikes.
    # 
    # @return [Array<Gear>] Athlete's gear
    def gear
      @gear.values
    end

    # Activities belonging to this user.
    # If no activities have been retrieved, an API call will be made. 
    # If activities exist, they will be returned.
    # Pagination is supported, and will always trigger an API call.
    # Paged requests will return the activities from that page.
    # Non-paged calls will return all downloaded activities.

    def activities(per_page: nil, page: nil)
      if page || per_page
        get_activities(per_page: per_page, page: page)
      else
        get_activities if @activities.empty?
        @activities.values
      end
    end

    # not working, not listed in docs
    # def heatmaps(per_page: nil, page: nil)
    #   if page || per_page
    #     get_heatmaps(per_page: per_page, page: page)
    #   else
    #     get_heatmaps if @heatmaps.empty?
    #     @heatmaps.values
    #   end
    # end

    def friends_activities(per_page: nil, page: nil, before: nil)
      if page || per_page
        get_friends_activities(per_page: per_page, page: page)
      else
        get_friends_activities if @friends_activities.empty?
        @friends_activities.values
      end
    end

    def stats
      @stats || get_stats
    end
    alias :totals :stats

    def zones
      @zones || get_zones
    end

    def koms(per_page: nil, page: nil)
      if page || per_page
        get_koms(per_page: per_page, page: page)
      else
        get_koms if @koms.empty?
        @koms.values
      end
    end

    def clubs
      get_clubs if @clubs.empty?
      @clubs.values
    end

    def routes(per_page: nil, page: nil)
      if page || per_page
        get_routes(per_page: per_page, page: page)
      else
        get_routes if @routes.empty?
        @routes.values
      end
    end

    def starred_segments(per_page: nil, page: nil)
      if page || per_page
        get_starred_segments(per_page: per_page, page: page)
      else
        get_starred_segments if @starred_segments.empty?
        @starred_segments.values
      end
    end

    def friends(per_page: nil, page: nil)
      # paginate('friends', struct: Array, per_page: per_page, page: page)
      if page || per_page
        get_friends(per_page: per_page, page: page)
      else
        get_friends if @friends.empty?
        @friends.uniq(&:id)
      end
    end

    def followers(per_page: nil, page: nil)
      # paginate('followers', struct: Array, per_page: per_page, page: page)
      if page || per_page
        get_followers(per_page: per_page, page: page)
      else
        get_followers if @followers.empty?
        @followers.uniq(&:id)
      end
    end

    def both_following(other_athlete, per_page: nil, page: nil)
      other_id = other_athlete.is_a?(Athlete) ? other_athlete.id : other_athlete
      if page || per_page
        get_both_following(other_id, per_page: per_page, page: page)
      else
        get_both_following(other_id) if @both_following[other_id].nil?
        @both_following[other_id]
      end
    end

    ## retrieval methods
    def get_details
      return self if detailed?
      res = client.get(path_base).to_h
      update(res)
    end

    private def get_activities(per_page: nil, page: nil)
      res = client.get(path_activities, per_page: per_page, page: page).to_a
      parse_data(@activities, res, klass: Activity, client: @client)
    end

    # not working, not listed in docs
    # private def get_heatmaps(per_page: nil, page: nil)
    #   res = client.get(path_heatmaps, per_page: per_page, page: page).to_a
    #   parse_data(@heatmaps, res, klass: Base, client: @client)
    # end

    private def get_friends_activities(per_page: nil, page: nil, before: nil)
      res = client.get(path_friends_activities, per_page: per_page, page: page, before: before).to_a
      parse_data(@friends_activities, res, klass: Activity, client: @client)
    end

    private def get_stats
      @stats = client.get(path_stats).to_h
    end

    private def get_zones
      @zones = client.get(path_zones).to_h
    end

    private def get_koms(per_page: nil, page: nil)
      res = client.get(path_koms, per_page: per_page, page: page).to_a
      parse_data(@koms, res, klass: SegmentEffort, client: @client)
    end

    private def get_clubs(per_page: nil, page: nil)
      res = client.get(path_clubs, per_page: per_page, page: page).to_a
      parse_data(@clubs, res, klass: Club, client: @client)
    end

    private def get_routes(per_page: nil, page: nil)
      res = client.get(path_routes, per_page: per_page, page: page).to_a
      parse_data(@routes, res, klass: Route, client: @client)
    end

    private def get_starred_segments(per_page: nil, page: nil)
      res = client.get(path_starred_segments, per_page: per_page, page: page).to_a
      parse_data(@starred_segments, res, klass: Segment, client: @client)
    end

    private def get_friends(per_page: nil, page: nil)
      res = client.get(path_friends, per_page: per_page, page: page).to_a
      data = parse_data(@connections, res, klass: self.class, client: @client)
      @friends.concat(data)
      data
    end

    private def get_followers(per_page: nil, page: nil)
      res = client.get(path_followers, per_page: per_page, page: page).to_a
      data = parse_data(@connections, res, klass: self.class, client: @client)
      @followers.concat(data)
      data
    end

    private def get_both_following(other_id, per_page: nil, page: nil)
      res = client.get(path_both_following(other_id), per_page: per_page, page: page).to_a
      @both_following[other_id] = parse_data(@connections, res, klass: self.class, client: @client)
    end

    def path_base
      current? ? 'athlete' : "athletes/#{id}"
    end

    private def path_activities
      current? ? "athlete/activities" : raise('Need to be current athlete')
    end

    # not working, not listed in docs
    # http://strava.github.io/api/v3/heatmaps/
    # private def path_heatmaps
    #   current? ? "athlete/heatmaps" : raise('Need to be current athlete')
    # end

    private def path_friends_activities
      current? ? "activities/following" : raise('Need to be current athlete')
    end

    private def path_stats
      current? ? "athletes/#{id}/stats" : raise('Need to be current athlete')
    end

    private def path_zones
      current? ? "athlete/zones" : raise('Need to be current athlete')
    end

    private def path_koms
      "athletes/#{id}/koms"
    end

    private def path_clubs
      current? ? "athlete/clubs" : raise('Need to be current athlete')
    end

    private def path_routes
      "athletes/#{id}/routes"
    end

    private def path_starred_segments
      current? ? "segments/starred" : "athletes/#{id}/segments/starred"
    end

    private def path_followers
      current? ? "athlete/followers" : "athletes/#{id}/followers"
    end
    private def path_friends
      current? ? "athlete/friends" : "athletes/#{id}/friends"
    end
    private def path_both_following(other_id)
      current? ? "athletes/#{other_id}/friends" : raise('Need to be current athlete')
    end

    private

    class << self
      # Retrieve the currently authenticated athlete. 
      # Will make request to Strava API.
      # 
      # @param token [String] access token for athlete
      # @return [Athlete] currently authenticated athlete
      def current_athlete(token = "ca16caf5b4cb8b57016541f470ae6b3a8aea2252")
        client = Client.new(token)
        res = client.get('athlete').to_h
        new(res, client: client, current: true)
      end

      # def path(endpoint)
      #   paths[endpoint]
      # end
      # def paths
      #   @paths ||= {
      #     current: 'athlete',
      #   }.freeze
      # end
    end
  end
end

__END__

ca = Strava::Athlete.current_athlete
