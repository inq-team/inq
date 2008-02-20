require File.dirname(__FILE__) + '/../test_helper'
require 'computers_controller'

# Re-raise errors caught by the controller.
class ComputersController; def rescue_action(e) raise e end; end

class ComputersControllerTest < Test::Unit::TestCase
	fixtures :computers, :profiles, :models, :testings, :testing_stages

	def setup
		@controller = ComputersController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_show
		get :show, :id => 1
		assert_response :redirect
	end

	def test_hw_1
		get :hw, :id => 1, :testing => 0
		assert_response :success
	end

	def test_hw_2
		get :hw, :id => 2, :testing => 0
		res = assigns['stages'].map { |s| s[:id] }
		assert_response :success
		assert_equal %w(cpu memory hdd-passthrough hdd-array net fdd odd_read), res
	end

	def test_plan_1
		get :plan, :id => 1
		res = assigns['pl'].plan.map { |t| t.type }
		assert_response :success
		assert_equal %w(cpu memory hdd-passthrough hdd-array net fdd odd_read), res
	end

	def test_plan_2
		get :plan, :id => 2
		res = assigns['pl'].plan.map { |t| t.type }
		assert_response :success
		assert_equal %w(cpu memory hdd-passthrough hdd-array net fdd odd_read), res
	end

	def test_plan_3
		get :plan, :id => 3
		res = assigns['pl'].plan.map { |t| t.type }
		assert_response :success
		assert_equal %w(memory hdd-passthrough hdd-array net fdd odd_read), res
	end
end
