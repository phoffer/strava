require 'test_helper'

class Strava::ActivityTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Strava::VERSION
  end
end
