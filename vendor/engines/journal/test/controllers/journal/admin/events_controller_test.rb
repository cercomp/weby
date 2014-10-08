require 'test_helper'

module Journal
  class Admin::EventsControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end

  end
end
