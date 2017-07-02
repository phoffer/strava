module Strava
  # Clubs represent groups of athletes on Strava. They can be public or private.
  # Clubs have both summary and detailed representations.
  # 
  # @see https://strava.github.io/api/v3/clubs/ Strava Docs - Clubs
  class Club < Base

    # Set up instance variables upon instantiation.
    #
    # @abstract
    # @return [void]
    private def set_ivars
      @activities       = {}
      @group_events     = {}
      @announcements    = []
      @members          = {}
      @admins           = []
      @segment_efforts  = {}
    end

    # Update an existing club. 
    # Used by other methods in the gem.
    # Should not be used directly.
    # 
    # @param data [Hash] data to update the club with
    # @return [self]
    def update(data, **opts)
      @response       = data
      @id             = data["id"]
      @resource_state = data['resource_state']

      self
    end

    def activities(per_page: nil, page: nil, before: nil)
      if page || per_page || before
        get_activities(per_page: per_page, page: page, before: before)
      else
        get_activities if @activities.empty?
        @activities.values
      end
    end

    def group_events(per_page: nil, page: nil, before: nil)
      if page || per_page || before
        get_group_events(per_page: per_page, page: page, before: before)
      else
        get_group_events if @group_events.empty?
        @group_events.values
      end
    end

    def announcements
      get_announcements if @announcements.empty?
      @announcements
    end

    def members(per_page: nil, page: nil)
      if page || per_page
        get_members(per_page: per_page, page: page)
      else
        get_members if @members.empty? || !@members_fetched
        @members_fetched = true
        @members.values
      end
    end

    def admins(per_page: nil, page: nil)
      if page || per_page
        get_admins(per_page: per_page, page: page)
      else
        get_admins if @admins.empty?
        @admins
      end
    end

    # {"success"=>true, "active"=>false}
    def join
      res = client.post(path_join).to_h
    end

    # {"success"=>true, "active"=>true, "membership"=>"member"}
    def leave
      res = client.post(path_leave).to_h
    end

    def get_details
      return self if detailed?
      res = client.get(path_base).to_h
      update(res)
    end

    private def get_activities(per_page: nil, page: nil, before: nil)
      res = client.get(path_activities, per_page: per_page, page: page, before: before).to_a
      parse_data(@activities, res, klass: Activity, client: @client)
    end

    private def get_group_events(per_page: nil, page: nil, before: nil)
      res = client.get(path_group_events, per_page: per_page, page: page, before: before).to_a
      parse_data(@group_events, res, klass: Activity, client: @client)
    end

    private def get_announcements
      res = client.get(path_announcements).to_a
      @announcements = parse_data({}, res, klass: ClubAnnouncement, client: @client)
    end

    private def get_members
      res = client.get(path_members).to_a
      parse_data(@members, res, klass: Athlete, client: @client)
    end

    private def get_admins
      res = client.get(path_admins).to_a
      @admins = parse_data(@members, res, klass: Athlete, client: @client)
    end

    private def path_base
      "clubs/#{id}"
    end

    private def path_activities
      "#{path_base}/activities"
    end

    private def path_group_events
      "#{path_base}/group_events"
    end

    private def path_announcements
      "#{path_base}/announcements"
    end

    private def path_members
      "#{path_base}/members"
    end

    private def path_admins
      "#{path_base}/admins"
    end

    private def path_join
      "#{path_base}/join"
    end

    private def path_leave
      "#{path_base}/leave"
    end

  end
end

__END__

ca = Strava::Athlete.current_athlete;
club = ca.clubs.last
club.admins
club.members
club.get_details
club.activities
club.group_events
club.announcements
club.leave
club.join
