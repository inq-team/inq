require File.dirname(__FILE__) + '/../test_helper'
require 'computers_controller'

# Re-raise errors caught by the controller.
class ComputersController; def rescue_action(e) raise e end; end

class ComputersControllerTest < Test::Unit::TestCase
	fixtures :computers, :profiles, :models, :testings, :testing_stages, :components, :component_models, :component_groups, :graphs, :firmwares, :computer_stages

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

	def test_mark_1
		get :mark, :id => 1
		assert_response :success
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

	def test_plan_5
		get :plan, :id => 5
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

	def test_submit_components_nils
		xml = "
<?xml version='1.0'?>
<list xmlns='http://www.w3.org/1999/xhtml'>
  <component>
    <type>RAM</type>
    <model>2048 GB</model>
  </component>
  <component>
    <type>RAM</type>
    <vendor />
    <model>2048 GB</model>
  </component>
</list>"		
		post :submit_components, :id => 2, :list => xml
		assert_equal 2, Computer.find(2).testings.size
		assert_equal 2, ComponentModel.find_all_by_component_group_id(3).size
		assert_equal 2, Component.find_all_by_component_model_id(ComponentModel.find_by_name('2048 GB').id).size
		assert_not_nil ComponentModel.find_by_name('2048 GB').vendor
		post :submit_components, :id => 2, :list => xml
		assert_equal 2, Computer.find(2).testings.size
	end

	def test_boot_from_image
		post :boot_from_image, :id => 20, :image => "rsbios.my"
		macs=assigns['macs']
		assert_equal ["00-e0-81-5d-4f-37", "00-e0-81-5d-4f-38"], macs
		assert_response :success
	end

	def test_firmware
		needed_firmwares = "NIC::810011::rs160g3.bios\nNIC::810011::rs160g3.bios\nRAM::1.0::memtester\n"
		get :get_needed_firmwares_list, :id => 20
		firmwares=assigns['firmwares']
		assert_equal needed_firmwares, firmwares
	end

	def test_monitoring_submit
		lt = Computer.find(2).last_testing
		qty = lt.graphs.size
		now = Time.new
		post :monitoring_submit, :id => 2, :monitoring_id => 1, :timestamp => now, :key => 1, :value => 42
		lt = Computer.find(2).last_testing
		assert_equal qty + 1, lt.graphs.size
		g = lt.graphs.last
		assert_equal 1, g.monitoring_id
		assert_equal now.to_s, g.timestamp.to_s
		assert_equal 1, g.key
		assert_equal 42, g.value
	end

	def test_set_checker_1
		cs1 = Computer.find(2).computer_stages.size
		post :set_checker, :id => 2, :checker_id => 1
		cs2 = Computer.find(2).computer_stages.size
		assert_equal cs1 + 1, cs2
		assert_equal 'checking', Computer.find(2).last_computer_stage.stage
		assert_equal 1, Computer.find(2).last_computer_stage.person_id
	end

	def test_set_checker_1
		cid = 2
		cs1 = Computer.find(cid).computer_stages.size
		post :set_checker, :id => cid, :checker_id => 1
		cs2 = Computer.find(cid).computer_stages.size
		assert_equal cs1 + 1, cs2
		assert_equal 'checking', Computer.find(cid).last_computer_stage.stage
		assert_equal 1, Computer.find(cid).last_computer_stage.person_id
		assert_nil Computer.find(cid).last_computer_stage.end
	end

	def test_set_checker_2
		cid = 1003
		cs1 = Computer.find(cid).computer_stages.size
		assert_equal 3, cs1
		post :set_checker, :id => cid, :checker_id => 1
		cs2 = Computer.find(cid).computer_stages.size
		assert_equal cs1, cs2
		assert_equal 'checking', Computer.find(cid).last_computer_stage.stage
		assert_equal 1, Computer.find(cid).last_computer_stage.person_id
		assert_not_nil Computer.find(cid).last_computer_stage.end
	end
end
