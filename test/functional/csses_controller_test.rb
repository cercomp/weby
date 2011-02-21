require 'test_helper'

class CssesControllerTest < ActionController::TestCase
  setup do
    @css = csses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:csses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create css" do
    assert_difference('Css.count') do
      post :create, :css => @css.attributes
    end

    assert_redirected_to css_path(assigns(:css))
  end

  test "should show css" do
    get :show, :id => @css.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @css.to_param
    assert_response :success
  end

  test "should update css" do
    put :update, :id => @css.to_param, :css => @css.attributes
    assert_redirected_to css_path(assigns(:css))
  end

  test "should destroy css" do
    assert_difference('Css.count', -1) do
      delete :destroy, :id => @css.to_param
    end

    assert_redirected_to csses_path
  end
end
