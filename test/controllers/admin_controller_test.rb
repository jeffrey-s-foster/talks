require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "index/spam hacker" do
    sign_in users(:user_hacker)
    get :index
    assert_redirected_to root_path
    get :spam
    assert_redirected_to root_path
  end

  test "index/spam admin" do
    sign_in users(:user_admin)
    get :index
    assert_response :success
    get :spam
    assert_response :success
  end
end
