require 'test_helper'

module Teachers
  class TeachersControllerTest < ActionController::TestCase
    setup do
      @teacher = teachers(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:teachers)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create teacher" do
      assert_difference('Teacher.count') do
        post :create, teacher: { email: @teacher.email, name: @teacher.name, website: @teacher.website }
      end
  
      assert_redirected_to teacher_path(assigns(:teacher))
    end
  
    test "should show teacher" do
      get :show, id: @teacher
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @teacher
      assert_response :success
    end
  
    test "should update teacher" do
      put :update, id: @teacher, teacher: { email: @teacher.email, name: @teacher.name, website: @teacher.website }
      assert_redirected_to teacher_path(assigns(:teacher))
    end
  
    test "should destroy teacher" do
      assert_difference('Teacher.count', -1) do
        delete :destroy, id: @teacher
      end
  
      assert_redirected_to teachers_path
    end
  end
end
