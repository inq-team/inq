require File.dirname(__FILE__) + '/../test_helper'
require 'profiles_controller'

# Re-raise errors caught by the controller.
class ProfilesController; def rescue_action(e) raise e end; end

class ProfilesControllerTest < Test::Unit::TestCase
	fixtures :profiles

	def setup
		@controller = ProfilesController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_should_get_index
		get :index
		assert_response :success
		assert assigns(:profiles)
	end

	def test_should_get_new
		get :new
		assert_response :success
	end

	def test_should_create_profile
		old_count = Profile.count
		post :create, :profile => { }
		assert_equal old_count+1, Profile.count
    		assert_redirected_to profile_path(assigns(:profile))
	end

	def test_should_show_profile
		get :show, :id => 1
		assert_response :success
	end

	def test_should_get_edit
		get :edit, :id => 1
		assert_response :success
	end

	def test_should_update_profile
		put :update, :id => 1, :profile => { }
		assert_redirected_to profile_path(assigns(:profile))
	end
end
