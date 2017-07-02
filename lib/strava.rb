require 'strava/version'
require 'strava/error'
require 'strava/usage'
require 'strava/client'
require 'strava/base'
require 'strava/gear'
require 'strava/segment'
require 'strava/segment_effort'
require 'strava/leaderboard'
require 'strava/leaderboard_entry'
require 'strava/athlete'
require 'strava/route'
require 'strava/activity'
require 'strava/stream_set'
require 'strava/stream'
require 'strava/lap'
require 'strava/comment'
require 'strava/photo'
require 'strava/club'
require 'strava/group_event'
require 'strava/club_announcement'
require 'strava/running_race'

module Strava

  class << self
    # @return [Integer, String] Strava Application ID
    attr_writer :client_id
    # @return [String] Strava Application secret
    attr_writer :client_secret

    # Helper for model classes.
    # Allows for convenient instantiation of current athlete.
    # This is completely agnostic to class type, it can be a DB model, a PORO, etc.
    # 
    # Usage:
    # 
    #     class Account < ApplicationRecord
    #       include Strava.model as: :athlete, via: :token, id: :strava_id
    #     end
    #     ca = Account.find(1).athlete # => Strava::Athlete
    # 
    # Can also perform lookup through another method:
    #
    #     class User < ApplicationRecord
    #       has_one :account
    #       include Strava.model as: :athlete, via: 'account.token', id: 'account.strava_id'
    #     end
    # 
    # @param as [Symbol] method to define to return current athlete
    # @param via [Symbol, String] method to lookup access token
    # @param id [Symbol, String] method to lookup Strava ID
    # @return [Module] module to be included in the calling class
    def model(as: :strava_athlete, via: :access_token, id: nil)
      Module.new.tap do |mod|
        str = <<~EOF
          def self.included(base)
            base.send(:define_method, :#{as}) { ::Strava::Athlete.new(#{id ? "{'id' => #{id}}" : '{}' }, token: #{via}, current: true) }
          end
        EOF
        mod.class_eval str
      end
    end

    # def adapter(name = :httparty)
    #   require "strava/adapters/#{name}"
    #   Client.include(Adapters.httparty)
    # end

    # @return [Integer, String] Strava Application ID
    def client_id
      @client_id ||= ENV['STRAVA_CLIENT_ID']
    end
    # @return [String] Strava Application secret
    def client_secret
      @client_secret ||= ENV['STRAVA_CLIENT_SECRET']
    end
  end
end
