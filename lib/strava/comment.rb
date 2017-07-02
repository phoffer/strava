module Strava
  # Class to represent Strava Activity
  # https://strava.github.io/api/v3/activities/
  class Comment < Base

    attr_reader :activity_id

    def update(data, **opts)
      @response = data
      @id             = data['id']
      @resource_state = data['resource_state']

      @text           = data['text']
      @activity_id    = data['activity_id']
      @athlete        = Athlete.new(data['athlete'], client: @client)
    end

    def delete
      res = client.delete(path_base).to_h
    end

    def path_base
      "activities/#{activity_id}/comments/#{id}"
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
