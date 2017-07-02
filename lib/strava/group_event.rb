module Strava
  # Group events for Strava Clubs
  # 
  # @see http://strava.github.io/api/v3/club_group_events/ Strava Docs - Group Events
  class GroupEvent < Base

    def update(data, **opts)
      @response = data
      @id                     = data["id"]
      @resource_state         = data['resource_state']
    end

    def get_details
      return self if detailed?
      res = client.get(path_base).to_h
      update(res)
      res
    end

    def athletes(per_page: nil, page: nil)
      if page || per_page
        get_athletes(per_page: per_page, page: page)
      else
        get_athletes if @athletes.empty?
        @athletes.values
      end
    end

    def delete
      res = client.delete(path_base).to_h
    end

    # {"success"=>true, "active"=>false}
    def join
      res = client.post(path_rsvp).to_h
    end

    # {"success"=>true, "active"=>true, "membership"=>"member"}
    def leave
      res = client.delete(path_rsvp).to_h
    end

    private def path_base
      "group_events/#{id}"
    end

    private def path_rsvp
      "#{path_base}/rsvps"
    end

    private def path_athletes
      "#{path_base}/athletes"
    end

  end
end

__END__

ca = Strava::Athlete.current_athlete;
miz = ca.clubs.last;
miz.group_events
