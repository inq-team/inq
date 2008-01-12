require File.dirname(__FILE__) + '/../test_helper'

class MarksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:marks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_mark
    assert_difference('Mark.count') do
      post :create, :mark => { }
    end

    assert_redirected_to mark_path(assigns(:mark))
  end

  def test_should_show_mark
    get :show, :id => marks(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => marks(:one).id
    assert_response :success
  end

  def test_should_update_mark
    put :update, :id => marks(:one).id, :mark => { }
    assert_redirected_to mark_path(assigns(:mark))
  end

  def test_should_destroy_mark
    assert_difference('Mark.count', -1) do
      delete :destroy, :id => marks(:one).id
    end

    assert_redirected_to marks_path
  end
end
