require File.dirname(__FILE__) + '/../test_helper'
require 'orders_controller'

# Re-raise errors caught by the controller.
class OrdersController; def rescue_action(e) raise e end; end

class OrdersControllerTest < Test::Unit::TestCase
	fixtures :orders, :computers, :profiles, :order_lines, :models

	def setup
		@controller = OrdersController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	# /order/show on order with already created computers
	def test_show_1
		get :show, :id => 1
		assert_equal(
			[
				["--", 0],
				["default (2000-01-01)", 1],
				["default (2000-01-01)", 9],
				["Alpha model: default (2000-02-01)", 3],
				["default (2000-02-02)", 2],
				["Alpha model: specific (2000-02-03)", 4],
				["Alpha model: default (2000-02-06)", 6],
				["Beta model: default (2000-02-06)", 7],
				["Alpha model: specific (2000-02-06)", 5],
				["groovy (2000-02-08)", 8]
			],
			assigns['profiles']
		)
	end

	# /order/show on order with computer creation dialog
	def test_show_2
		get :show, :id => 2
		assert_equal(
			[
				["Alpha model: default (2000-02-06)", 6],
				["Alpha model: specific (2000-02-06)", 5],
				["default (2000-02-02)", 2],
			],
			assigns['profiles']
		)
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
