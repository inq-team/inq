require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase
	fixtures :profiles

	def test_name
		assert_equal 'default (2000-01-01)', Profile.find(1).name
		assert_equal 'Alpha model: default (2000-02-01)', Profile.find(3).name
		assert_equal 'Alpha model: specific (2000-02-03)', Profile.find(4).name
		assert_equal 'Alpha model: specific (2000-02-06)', Profile.find(5).name
		assert_equal 'Alpha model: default (2000-02-06)', Profile.find(6).name
	end
end
