require 'httparty'
module Strava
  class Client
    attr_reader :token
    # @return [Usage] Information on API quota usage
    attr_reader :usage
    BASE_URL = 'https://www.strava.com/api/v3/' # can be overridden for individual requests

    def initialize(token)
      @token = token
    end

    def get(path, **params)
      make_request(:get, path, **params)
    end

    def post(path, **params)
      make_request(:post, path, **params)
    end

    def put(path, **params)
      make_request(:put, path, **params)
    end

    def delete(path, **params)
      make_request(:delete, path, **params)
    end

    def make_request(verb, path, **params)
      puts (params[:host] || BASE_URL) + path
      handle_params(params)
      res = HTTParty.send(verb, (params.delete(:host) || BASE_URL) + path, query: params)
      check_for_error(res)
      res
    end

    def handle_params(params)
      if @token
        params.merge!(access_token: @token)
      else
        params.merge!(client_id: Strava.client_id, client_secret: Strava.secret)
      end
      params.reverse_each { |k, v| params.delete(k) if v.nil? }
    end

    def check_for_error(response)
      @usage = Usage.new(response.headers['X-Ratelimit-Limit'], response.headers['X-Ratelimit-Usage'])
      case response.code
      when 401, 403
        raise Strava::AccessError.new(response.to_h)
      end
    end


    ## non athlete calls
    def list_races(year = Time.now.year)
      RunningRace.list_races(self, year)
    end

    def segment_explorer(bounds = '37.821362,-122.505373,37.842038,-122.465977')
      Segment.explorer(self, bounds)
    end

  end
end
