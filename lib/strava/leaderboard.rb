module Strava
  class Leaderboard < Base
    # Class to represent Strava Activity
    # https://strava.github.io/api/v3/activities/
    # Your code goes here...

    def set_ivars
      @entries      = {}
    end

    def standings
      @entries.values.sort { |a, b| a.rank <=> b.rank }
    end
    alias :entries :standings

    def update(data, **opts)
      @response = data
      @segment_id = data['segment_id'] if data['segment_id']

      @entry_count  = data['entry_count'] if data['entry_count']
      if data['entries']
        data['entries'].each { |hash| hash['id'] = hash['effort_id'] }
        parse_data(@entries, data['entries'], klass: LeaderboardEntry, client: @client)
      end

      self
    end

    def get_details
      return self if detailed?
      res = client.get(path_base).to_h
      update(res)
      res
    end

    def get_standings(per_page: nil, page: nil, **params)
      res = client.get(path_base, per_page: per_page, page: page, **params).to_h
      update(res)
    end

    def path_base
      "segments/#{@segment_id}/leaderboard"
    end


  end
end

__END__

ca = Strava::Athlete.current_athlete;
rlk = ca.friends.detect{|a| a.id == 3635502 };
segments = rlk.starred_segments;
seg = segments.first
seg.leaderboard
seg.leaderboard.get_standings;
seg.leaderboard.standings
