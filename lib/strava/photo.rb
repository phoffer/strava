module Strava
  # Strava allows for attaching photos to activities. These photos can come from either Instagram or be uploaded directly to Strava.
  # Initially, only Instagram was supported. Later, Strava began storing photos on its own.
  # 
  # Example:
  # 
  #     ca = Strava::Athlete.current_athlete
  #     activity = ca.activities.detect{ |a| a.total_photo_count > 0 }  # Find activity with any photos, Strava or Instagram.
  #     activity = ca.activities.detect{ |a| a.photo_count > 0 }        # Check for Instagram photos only
  #     activity.photos                                                 # Array of `Photo` objects
  # 
  # @see https://strava.github.io/api/v3/activity_photos/ Strava Docs - Activity Photos
  class Photo < Base

    # Updates photo with passed data attributes.
    # 
    # @private
    # @param data [Hash] data hash containing photo data
    # @return [self]
    def update(data, **opts)
      @resource_state = data['resource_state']
      @activity_id    = data['activity_id']
      @ref            = data["ref"]
      @uid            = data["uid"]
      @caption        = data["caption"]
      @type           = data["type"]
      @uploaded_at    = data["uploaded_at"]
      @created_at     = data["created_at"]
      @location       = data["location"]
    end

  end
end

__END__

ca = Strava::Athlete.current_athlete;
ca.activities;
ca.activities(page: 1, per_page: 200);
ca.activities(page: 2, per_page: 200);
ca.activities(page: 3, per_page: 200);
ca.activities(page: 4, per_page: 200);
ca.activities(page: 5, per_page: 200);
ca.activities(page: 6, per_page: 200);
ca.activities(page: 7, per_page: 200);
ca = Strava::Athlete.current_athlete;
activity = ca.activities.detect{ |a| a.response['photo_count'] > 0 } # insta only
activity = ca.activities.detect{ |a| a.response['total_photo_count'] > 0 } # include strava photos
activity.photos
activity.comments
