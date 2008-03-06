require File.dirname(__FILE__) + '/../test_helper'
require 'computers_controller'

# Re-raise errors caught by the controller.
class ComputersController; def rescue_action(e) raise e end; end

class ComputersControllerTest < Test::Unit::TestCase
	fixtures :computers, :profiles, :models, :testings, :testing_stages, :components, :component_models, :component_groups, :graphs

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

	def test_submit_components_1
		post :submit_components, :id => 2, :list => "
<?xml version='1.0'?>
<list xmlns='http://www.w3.org/1999/xhtml'>
  <component>
    <type>NIC</type>
    <vendor>nVidia</vendor>
    <model>MCP55 Ethernet</model>
    <serial>00:a0:d1:e3:13:b6</serial>
  </component>
</list>"
		assert_equal 2, Computer.find(2).testings.size
	end

	def test_submit_components_2
		post :submit_components, :id => 2, :list => "
<?xml version='1.0'?>
<list xmlns='http://www.w3.org/1999/xhtml'>
  <component>
    <type>CPU</type>
    <vendor>AMD</vendor>
    <model>Athlon</model>
  </component>
  <component>
    <type>HDD</type>
    <vendor>Seagate</vendor>
    <model>Barracuda 160GB</model>
    <serial>SERIAL2</serial>
  </component>
  <component>
    <type>HDD</type>
    <vendor>Seagate</vendor>
    <model>Barracuda 160GB</model>
    <serial>SERIAL3</serial>
  </component>
</list>"
		assert_equal 1, Computer.find(2).testings.size
	end

	def test_monitoring_submit
		lt = Computer.find(2).last_testing
		qty = lt.graphs.size
		post :monitoring_submit, :id => 2, :monitoring_id => 1, :timestamp => 12345678, :key => 1, :value => 42
		assert_equal qty + 1, lt.graphs.size
		g = lt.graphs[0]
		assert_equal 1, g.monitoring_id
		assert_equal 12345678, g.timestamp
		assert_equal 1, g.key
		assert_equal 42, g.value
	end
end
