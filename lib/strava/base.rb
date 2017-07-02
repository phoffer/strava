module Strava
  # Base class for Strava objects.
  # Handles setting up the object, mainly data and a client.
  # 
  # @abstract
  class Base
    attr_reader :response, :client, :id

    def initialize(data, client: nil, token: nil, **opts)
      raise 'missing client or access token' unless (client || token)
      @client   = client || Client.new(token)
      if data.is_a?(Hash)
        @id       = data['id']
        set_ivars
        update(data, **opts)
      else
        @id = data
        set_ivars
      end
    end

    # Parse incoming data.
    # Should be defined by subclasses.
    #
    # @abstract
    def update(data, **opts)
      @response       = data
      @resource_state = data['resource_state']
      self
    end

    # Set up instance variables upon instantiation.
    # Should be defined by subclasses.
    # May not always be necessary.
    #
    # @abstract
    # @return [void]
    private def set_ivars
      # this should be defined by subclasses
    end

    private def parse_data(existing, data, klass: nil, **opts)
      existing ||= {}
      case data
      when [], {}
        []
      when Array
        data.map do |hash|
          current = existing[hash['id']]
          if current
            current.send(:update, hash, **opts)
          else
            current = klass.new(hash, **opts)
            existing[current.id] = current
          end
          existing[current.id]
        end
      when Hash
        existing[data['id']] = klass.new(data, **opts)
      else
        # raise
      end
    end

    def resource_state
      self.class.resource_states[@resource_state]
    end

    def summary?
      @resource_state == 2
    end

    def detailed?
      @resource_state == 3
    end

    def self.resource_states
      @resource_states ||= {
        1 => 'meta',
        2 => 'summary',
        3 => 'detailed',
      }
    end

  end
end
