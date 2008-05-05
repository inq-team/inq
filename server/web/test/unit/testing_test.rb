require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < Test::Unit::TestCase
	fixtures :testings, :testing_stages

	def test_close_hanging_1
		t = Testing.find(70)
		assert_equal true, t.close_hanging
		assert_not_nil t.test_end
		ts = t.testing_stages
		assert_equal 1, ts.size
		assert_equal TestingStage::HANGING, ts[0].result
		assert_not_nil ts[0].end
	end
end
