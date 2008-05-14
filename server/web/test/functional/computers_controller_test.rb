require File.dirname(__FILE__) + '/../test_helper'
require 'computers_controller'
require 'fileutils'

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

	def test_plan_6
		get :plan, :id => 6
		res = assigns['pl'].plan.map { |t| t.type }
		assert_response :success
		assert_equal %w(hdd-passthrough hdd-array), res
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
		post :submit_components, :id => 3, :list => "
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
		assert_equal 1, Computer.find(3).testings.size
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

	def test_submit_components_switch_profile
		c = Computer.find(2)
		c.profile_id = 9
		c.save!
		post :submit_components, :id => 2, :list => "<?xml version='1.0'?>
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
		assert_equal 2, Computer.find(2).testings.size		
	end

	# Computer 5 has 2 closed testings, submitting same components should start testing #3
	def test_submit_components_after_closed_testing_same_components
		post :submit_components, :id => 5, :list => "<?xml version='1.0'?>
<list xmlns='http://www.w3.org/1999/xhtml'>
  <component>
    <type>CPU</type>
    <vendor>AMD</vendor>
    <model>Athlon</model>
    <serial>0</serial>
  </component>
  <component>
    <type>CPU</type>
    <vendor>AMD</vendor>
    <model>Athlon</model>
    <serial>SERIAL2</serial>
  </component>
</list>"
		c = Computer.find(5)
		assert_equal 3, c.testings.size

		c1 = c.testings[1].components
		c2 = c.testings[2].components
		assert_equal c1.size, c2.size

		assert_block('Components differ, while they should be the same') {
			res = true
			c1.size.times { |i| res = false unless c1[i] === c2[i] }
			return res
		}
	end

	# Computer 5 has 2 closed testings, submitting different components should start testing #3
	def test_submit_components_after_closed_testing_diff_components
		post :submit_components, :id => 5, :list => "<?xml version='1.0'?>
<list xmlns='http://www.w3.org/1999/xhtml'>
  <component>
    <type>CPU</type>
    <vendor>AMD</vendor>
    <model>Athlon</model>
    <serial>000</serial>
  </component>
  <component>
    <type>HDD</type>
    <vendor>Seagate</vendor>
    <model>Barracuda 160GB</model>
    <serial>SERIAL3</serial>
  </component>
</list>"
		assert_equal 3, Computer.find(5).testings.size		
	end

	# Computer X has unclosed testing with 1 running test_stage =>
	# new testing should be started, all other test_stages should be
	# closed as hanging
	def test_submit_components_running_test_stages
		post :submit_components, :id => 7, :list => "
<?xml version='1.0'?>
<list xmlns='http://www.w3.org/1999/xhtml'>
  <component>
    <type>CPU</type>
    <vendor>AMD</vendor>
    <model>Athlon</model>
    <serial>000</serial>
  </component>
</list>"
		c = Computer.find(7)
		assert_equal 2, c.testings.size
		t0 = c.testings[0]
		assert_not_nil t0.test_end
		assert_equal TestingStage::HANGING, t0.testing_stages[0].result
		assert_not_nil t0.testing_stages[0].end
	end

	# Computer 8 had a single component (HDD) and passed many
	# test_stages in single testing.

	# Nothing was changed in configuration, but it was occasionally
	# restarted. No new testings/test stages should be started.
	def test_retest_after_nothing
		post :submit_components, :id => 8, :list => "
<?xml version='1.0'?>
<list xmlns='http://www.w3.org/1999/xhtml'>
  <component>
    <type>HDD</type>
    <vendor>Seagate</vendor>
    <model>Barracuda 160GB</model>
    <serial>OLD</serial>
  </component>
</list>"
		assert_equal 1, Computer.find(8).testings.size
		get :plan, :id => 8
		res = assigns['pl'].plan.map { |t| t.type }
		assert_response :success
		assert_equal [], res				
	end

	# After a while HDD was replaced and new testing initiated. Only
	# HDD-related tests should be planned.
	def test_retest_after_changing_hdds
		post :submit_components, :id => 8, :list => "
<?xml version='1.0'?>
<list xmlns='http://www.w3.org/1999/xhtml'>
  <component>
    <type>HDD</type>
    <vendor>Seagate</vendor>
    <model>Barracuda 160GB</model>
    <serial>NEW</serial>
  </component>
</list>"
		assert_equal 2, Computer.find(8).testings.size
		get :plan, :id => 8
		res = assigns['pl'].plan.map { |t| t.type }
		assert_response :success
		assert_equal %w(hdd-passthrough hdd-array), res
	end

	def test_boot_from_image
		# Create temporary "BIOS-image" file and pxelinux.cfg directory
		tmpfile = rand(100).to_s
		f = File.new("#{TFTP_DIR}/#{tmpfile}", "w")
		f.close
		FileUtils.mkdir("#{TFTP_DIR}/pxelinux.cfg")

		post :boot_from_image, :id => 20, :image => tmpfile
		macs = assigns['macs']
		assert_equal ["00-e0-81-5d-4f-37", "00-e0-81-5d-4f-38"], macs

		needed = "#pxelinux.cfg/01-00-e0-81-5d-4f-37 pxelinux.cfg/01-00-e0-81-5d-4f-38\n";
		needed = needed + "default firmware\nlabel firmware\n";
		needed = needed + " kernel memdisk\n append initrd=#{tmpfile} \n"

		file = File.open("#{TFTP_DIR}/pxelinux.cfg/01-00-e0-81-5d-4f-37")
		got = ""
		while (l = file.gets)
			got = got + l
		end
		assert_equal needed, got

		file = File.open("#{TFTP_DIR}/pxelinux.cfg/01-00-e0-81-5d-4f-38")
		got = ""
		while (l = file.gets)
			got = got + l
		end
		assert_equal needed, got

		assert_response :success

		FileUtils.rm("#{TFTP_DIR}/pxelinux.cfg/01-00-e0-81-5d-4f-37")
		FileUtils.rm("#{TFTP_DIR}/pxelinux.cfg/01-00-e0-81-5d-4f-38")
		FileUtils.rm("#{TFTP_DIR}/#{tmpfile}")
		FileUtils.rmdir("#{TFTP_DIR}/pxelinux.cfg")
	end

	def test_firmware
		needed_firmwares = "NIC::810011::rs160g3.bios\nNIC::810011::rs160g3.bios\nRAM::1.0::memtester\n"
		get :get_needed_firmwares_list, :id => 20
		firmwares = assigns['firmwares']
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

	def test_attention
		cid = 7
		post :advance, :id => cid, :stage => 'cpu', :event => 'require_attention'
		ts = Computer.find(cid).last_testing.testing_stages
		assert_equal 1, ts.size
		assert_equal TestingStage::ATTENTION, ts.first.result
		assert_not_nil ts.first.end
		assert_equal 0, ts.first.accumulated_idle

		sleep 0.5

		post :advance, :id => cid, :stage => 'cpu', :event => 'dismiss_attention'
		ts = Computer.find(cid).last_testing.testing_stages
		assert_equal 1, ts.size
		assert_equal TestingStage::RUNNING, ts.first.result
		assert_nil ts.first.end
		assert_not_equal 0, ts.first.accumulated_idle
	end
end
