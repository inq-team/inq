require File.dirname(__FILE__) + '/../test_helper'
require 'orders_controller'

# Re-raise errors caught by the controller.
class OrdersController; def rescue_action(e) raise e end; end

class OrdersControllerTest < Test::Unit::TestCase
	fixtures :orders, :computers, :profiles, :order_lines

	def setup
		@controller = OrdersController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_create_computers_1
		post :create_computers, {
			:id => 1,
			:model => { :id => 2 },
			:new_computers => { :start_id => 500, :end_id => 505, :qty => 6 },
			:profile => { :id => 1 },
		}
		assert_response :redirect
		(500..505).each { |i|
			c = Computer.find(i)
			assert_equal 2, c.model_id
			assert_equal 1, c.order_id
			assert_equal 1, c.profile_id
		}
		[498, 499, 506, 507].each { |i|
			assert_nil Computer.find_by_id(i)
		}
	end
end
