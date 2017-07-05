# Strava

Interact with [Strava's v3 API](https://strava.github.io/api/). This gem is designed to be fully object oriented, so most interaction is with Strava objects. There is an existing gem [strava-api-v3](https://github.com/jaredholdcroft/strava-api-v3), which has been around much longer and has some extra functionality. It is more functional and typically deals with JSON data. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'strava'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install strava

## API Notes

### Detail Level

All Strava resources have a detail level, `{1 => meta, 2 => summary, 3 => detailed}`. Objects will have a `#get_details` method which retrieves the full object details, if supported and not already fetched.

### Pagination

Many Strava endpoints support optional pagination. All of these endpoints accept `:page` and `:per_page` options. These can be used like `athlete.activities(page: 3)`. Refer to the [API Coverage](#api-coverage) section for a list of endpoints supporting pagination.

All method calls including pagination will trigger an API call and return the items from that call. Any calls without pagination will return all previously downloaded items. If no requests have been made, a request without pagination will be made.

## Functionality

### Configuration

This is not necessary, as only the webhooks API requires application information. The values shown below are used by default if not configured manually.

```ruby
Strava.client_id = ENV['STRAVA_CLIENT_ID']
Strava.secret = ENV['STRAVA_CLIENT_SECRET']
```

### Current Athlete

Generally, most of the Strava API is based off the authenticated user. Thus, most of the gem's functionality flows from the athlete class (either authenticated user or another).

The quickest way to get started is with the currently authenticated athlete:

```ruby
ca = Strava::Athlete.current_athlete(access_token) # => Strava::Athlete
```

There is also a mixin for existing classes (i.e. models). It is agnostic to DBs/adapters/etc, and only requires a method for the access token.

```ruby
class Account < ApplicationRecord
  include Strava.model as: :athlete, via: :token, id: :strava_id
end
ca = Account.find(1).athlete # => Strava::Athlete
```

This will add an instance method `#athlete` to the `User` class. This returns a `Strava::Athlete`, populating the access token with `User#token` and the user ID with `User#strava_id`. All 3 parameters are optional, and the default parameters are `{ via: :access_token, as: :strava_athlete, id: nil }`.

It can also be used to go through another method, for instance, if you have separate user and account models:

```ruby
class User < ApplicationRecord
  has_one :account
  include Strava.model as: :athlete, via: 'account.token', id: 'account.strava_id'
end
ca = User.find(1).athlete # => Strava::Athlete
```

### Classes

Most use cases won't include manually instantiating classes. Instead, interaction starts with a user and then flows through related objects. If desired, classes can be instantiated, with two requirements:

1. First argument must be either the object ID (string or integer accepted), or a hash with an `'id'` key.
1. Either the `token` or `client` keyword argument must be passed. All API interaction requires an access_token, so instantiation does too.

```ruby
act = Strava::Activity.new(321934, token: '83ebeabdec09f6670863766f792ead24d61fe3f9')
act = Strava::Activity.new({'id' => 321934}, client: Strava::Client.new('83ebeabdec09f6670863766f792ead24d61fe3f9'))
```

## Usage

### Athlete

[Strava Docs](https://strava.github.io/api/v3/athlete/)

Strava uses the phrase _currently authenticated athlete_ throughout their docs, so we'll use the term _current_ to represent that athlete. With the current athlete from above, we can request data for that athlete. Some APIs can only be made on behalf of the current athlete. See Strava docs for further information.

```ruby
ca.get_details              # => retrieves full representation of the athlete
ca.email                    # => "john@applestrava.com"
ca.firstname                # => "John"
ca.lastname                 # => "Applestrava"
ca.stats                    # => Hash of athlete stats
ca.zones                    # => Array of HR/power zones (hash)
ca.koms                     # => [Strava::SegmentEffort]
ca.friends                  # => [Strava::Athlete]
ca.followers                # => [Strava::Athlete]
ca.both_following(other_id) # => [Strava::Athlete]

# listed in docs other than athlete docs
ca.clubs            # => [Strava::Club]
ca.routes           # => [Strava::Route]
ca.starred_segments # => [Strava::Segment]
```

### Activity

[Strava Docs](https://strava.github.io/api/v3/activities/)

Strava provides extensive data on activities. 

```ruby
activity = ca.activities.first # => Strava::Activity
activity.get_details           # => retrieves full representation of the activity
activity.comments              # => [Strava::Comment]
activity.kudos                 # => [Strava::Kudo]
activity.photos                # => [Strava::Photo]
activity.related               # => [Strava::Activity] activities that were matched as “with this group”
activity.zones                 # => Array of HR/Power zones
activity.laps                  # => [Strava::Lap]
activity.streams               # => [Strava::StreamSet] Without args, will retrieve time, distance, latlng streams

# Strava Partner APIs
activity.comment(message)      # => Create a comment on an activity
activity.kudo                  # => Kudo an activity
```

### Club

[Strava Docs](https://strava.github.io/api/v3/clubs/)

```ruby
club = ca.clubs.first # => Strava::Club
club.get_details      # => retrieves full representation of the club
club.activities       # => [Strava::Activity]
club.group_events     # => [Strava::GroupEvent]
club.announcements    # => [Strava::ClubAnnouncment]
club.members          # => [Strava::Athlete]
club.admins           # => [Strava::Athlete]
club.join             # => Join the club as current athlete. Returns hash for success or failure
club.leave            # => Leave the club as current athlete. Returns hash for success or failure
```

### Group Event

[Strava Docs](https://strava.github.io/api/v3/club_group_events/)

```ruby
ge = club.group_events.first  # => Strava::GroupEvent
ge.get_details                # => retrieves full representation of the group event
ge.athletes                   # => [Strava::Athlete]
ge.delete                     # => Delete group event. Must have edit permissions. Returns hash of success/failure
ge.join                       # => Join the event as current athlete. Returns hash of success/failure
ge.leave                      # => Leave the event as current athlete. Returns hash of success/failure
```

### Gear

[Strava Docs](https://strava.github.io/api/v3/gear/)

```ruby
gear = ca.gear.first  # => Strava::Gear
gear.get_details      # => retrieves full representation of the gear
```

### Route

[Strava Docs](https://strava.github.io/api/v3/routes/)

```ruby
route = ca.routes.first # => Strava::Route
route.get_details       # => retrieves full representation of the route
route.streams           # => [Strava::StreamSet] Retrieves distance, altitude, latlng streams (no other streams available).
```

### Running Race

[Strava Docs](https://strava.github.io/api/v3/running_races/)

Races are different, as they don't flow from the current athlete. However, the Race APIs still require authentication. As such, there are a couple ways to retrieve races:

```ruby
# List races via the current athlete. Probably the simplest way.
races = ca.list_races

# List races via the `RunningRace` class. Must provide an API client.
client = Strava::Client.new('83ebeabdec09f6670863766f792ead24d61fe3f9')
races = RunningRace.list_races(client)

# List races via a client. The gem is designed to minimize interaction with the Client class, but it's available if desired.
client = Strava::Client.new('83ebeabdec09f6670863766f792ead24d61fe3f9')
races = client.list_races

# All methods accept an optional argument for the year:
races = ca.list_races(2016)
races = RunningRace.list_races(client, 2016)
races = client.list_races(2016)

# The only API interaction available for a race is to retrieve more details.
races.first.get_details # Returns the race, with full representation.
```

### Segment

[Strava Docs](https://strava.github.io/api/v3/segments/)

```ruby
segment = ca.starred_segments.first # => Strava::Segment
segment.get_details                 # => retrieves full representation of the segment
segment.efforts                     # => [Strava::SegmentEffort] Segment efforts for the current athlete
segment.streams                     # => [Strava::StreamSet] Retrieves distance, altitude, latlng streams (no other streams available).
segment.star                        # => Star the segment, on behalf of current athlete. Returns hash of success/failure.
segment.unstar                      # => Unstar the segment, on behalf of current athlete. Returns hash of success/failure.

# segment explorer is similar to the running races API. It can be called via a user:
bounds = '37.821362,-122.505373,37.842038,-122.465977' # => ‘south,west,north,east
ca.segment_explorer(bounds)

# Or via the `Segment` class. Must provide an API client.
segments = Segment.explorer(client, bounds)

# or via a client (discouraged)
client.segment_explorer(bounds)
```


### Segment Effort

[Strava Docs](https://strava.github.io/api/v3/efforts/)

```ruby
effort = segment.efforts.first  # => Strava::SegmentEffort
effort.get_details              # => retrieves full representation of the segment
effort.streams                  # => [Strava::StreamSet] Retrieves distance, altitude, latlng streams (no other streams available).
```

### StreamSet

[Strava Docs](https://strava.github.io/api/v3/streams/)

```ruby
activity.streams
activity.streams.all
```

### Uploads

[Strava Docs](https://strava.github.io/api/v3/uploads/)

Uploads haven't been implemented yet :( It will be soon though!

### Auth

[Strava Docs](https://strava.github.io/api/v3/oauth/)

Auth hasn't been implemented yet :( However, most apps are probably using omniauth, so this is a bit lower on the priority list.

### Webhooks

[Strava Docs](https://strava.github.io/api/v3/events/)

Webhooks haven't been implemented yet :( It will be soon though!

## TODO

1. Continue adding YARD Documentation
1. Add tests
1. Submit PRs to existing gem

## Why

Q. Why aren't there tests?
A. Tests are in progress. Unfortunately, there is no test environment for Strava, and virtually everything is based on hitting their API.

Q. Why not contribute to the existing gem?
A. I'm planning on it! But I also wanted something a bit more OO, and wanted to see what I could come up with.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/phoffer/strava.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

