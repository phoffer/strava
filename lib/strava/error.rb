{"message"=>"Authorization Error", "errors"=>[{"resource"=>"AccessToken", "field"=>"write_permission", "code"=>"missing"}]}

module Strava
  class Error < StandardError
    attr_accessor :response, :strava_errors
  end

  class AccessError < Error
    def initialize(response)
      message = response['message']
      strava_errors = response['errors']
      super(message)
    end
  end
end
