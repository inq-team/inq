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

	def test_hw
		get :hw, :id => 1, :testing => 0
		assert_response :success
	end

	def test_plan_1
		get :plan, :id => 1
		assert_response :success
#		p assigns['pl'].script
		assert_equal assigns['pl'].script, <<__EOF__
PLANNER=1 TEST_NAME=cpu TESTTIME=1800 run_test cpu
PLANNER=1 TEST_NAME=memory TEST_LOOPS=1 LOGTIME=120 run_test memory
PLANNER=1 TEST_NAME=hdd-passthrough DISK_GROUP_SIZE=8 run_test hdd-passthrough
PLANNER=1 TEST_NAME=hdd-array JOBS=16 TIMEOUT=3600 STRESS_TREE=/usr/share/inquisitor/linux-2.6.22.5-31-stress.tar.gz LOGTIME=120 run_test hdd-array
PLANNER=1 TEST_NAME=net URL=3000/test_file.html TIMEOUT=30 MD5=ca658fd4159bc35698edf9a1cdd70876 run_test net
PLANNER=1 TEST_NAME=fdd FLOPPY_SIZE=1440 run_test fdd
PLANNER=1 TEST_NAME=odd_read MESH_POINTS=1024 TEST_IMAGE_BLOCKS=50000 FORCE_NON_INTERACTIVE=false TEST_IMAGE_HASH=2e8744dfd11bf425001aad57976d42cc run_test odd_read
__EOF__
	end
end
