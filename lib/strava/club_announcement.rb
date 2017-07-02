module Strava
  # Class to represent Strava Club Announcement
  # https://strava.github.io/api/v3/activities/
  class ClubAnnouncement < Base

    def update(data, **opts)
      @response = data
      @id             = data['id']
      @resource_state = data['resource_state']

      @message        = data['message']
      @created_at     = data['created_at']
      @club_id        = data['club_id']
      @athlete        = Athlete.new(data['athlete'], client: @client)
    end

  end
end

__END__

ca = Strava::Athlete.current_athlete;
ca.activities;
ca.activities(page: 2);
ca.activities(page: 3);
ca.activities(page: 4);
act = ca.activities.detect{|act| act.response['comment_count'] > 0 && act.response['kudos_count'] > 0 }
act.comments
