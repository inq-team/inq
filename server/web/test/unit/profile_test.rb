require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase
	fixtures :profiles

	def test_name_1
		assert_equal 'default (2000-01-01)', Profile.find(1).name
	end
end
