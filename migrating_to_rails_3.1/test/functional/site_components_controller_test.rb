require 'test_helper'

class SiteComponentsControllerTest < ActionController::TestCase
  setup do
    @site_component = site_components(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:site_components)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create site_component" do
    assert_difference('SiteComponent.count') do
      post :create, :site_component => @site_component.attributes
    end

    assert_redirected_to site_component_path(assigns(:site_component))
  end

  test "should show site_component" do
    get :show, :id => @site_component.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @site_component.to_param
    assert_response :success
  end

  test "should update site_component" do
    put :update, :id => @site_component.to_param, :site_component => @site_component.attributes
    assert_redirected_to site_component_path(assigns(:site_component))
  end

  test "should destroy site_component" do
    assert_difference('SiteComponent.count', -1) do
      delete :destroy, :id => @site_component.to_param
    end

    assert_redirected_to site_components_path
  end
end
