module Strava
  class StreamSet
    # Class to contain Strava Streams
    # http://strava.github.io/api/v3/streams/

    attr_reader :type, :data
    def initialize(data = {})
      @streams = {}
      update(data)
    end

    def all
      size = @streams.values.first.size
      size.times.map do |i|
        @streams.map do |type, stream|
          [type, stream[i]]
        end.to_h
      end
    end

    def all2
      size = @streams.values.first.size
      size.times.map do |i|
        @streams.map do |type, stream|
          { type => stream[i] }
        end.inject(:merge)
      end
    end

    def empty?
      @streams.empty?
    end

    def update(data, **opts)
      @response = data

      data.each do |stream_data|
        stream = Stream.new(stream_data)
        @streams[stream.type] = stream
      end

      self
    end

    def time;            @streams['time'];            end
    def latlng;          @streams['latlng'];          end
    def distance;        @streams['distance'];        end
    def altitude;        @streams['altitude'];        end
    def velocity_smooth; @streams['velocity_smooth']; end
    def heartrate;       @streams['heartrate'];       end
    def cadence;         @streams['cadence'];         end
    def watts;           @streams['watts'];           end
    def temp;            @streams['temp'];            end
    def moving;          @streams['moving'];          end
    def grade_smooth;    @streams['grade_smooth'];    end

  end
end

__END__

ca = Strava::Athlete.current_athlete;
