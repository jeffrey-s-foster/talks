require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "index not admin" do
      get :index
      assert_redirected_to root_path
  end

  test "index admin" do
    sign_in users(:user_admin)
    get :index
    assert_response :success
  end

end
