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

	def test_list_for_model
		assert_equal [6,5,2,8], Profile.list_for_model(1).collect { |x| x.id }
		assert_equal [7,2,8], Profile.list_for_model(2).collect { |x| x.id }
	end
end
