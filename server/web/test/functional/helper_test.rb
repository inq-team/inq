require File.dirname(__FILE__) + '/../test_helper'

class HelperTest < Test::Unit::TestCase

	include ApplicationHelper

	def test_delta
		time1 = Time.new()
		time2 = time1 + 3600 * 24
		txt = format_delta(time2, time1)
		assert_match(/d/, txt)
		time1 = Time.new()
		time2 = time1 + 59
		txt = format_delta(time2, time1)
		assert_match(/s/, txt)
		time1 = Time.new()
		time2 = time1 + 3600 * 24 - 1
		txt = format_delta(time2, time1)
		assert_match(/\d+h \d+m/, txt)
		txt = format_delta(time1, time1)
		assert_match(/s/, txt)
	end

end
