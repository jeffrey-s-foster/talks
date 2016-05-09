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

  test "show not logged in" do
    get :show, id: users(:user_plain)
    assert_redirected_to root_path
  end

  test "show admin" do
    sign_in users(:user_admin)
    get :show, id: users(:user_plain)
    assert_response :success
  end

  test "show hacker" do
    sign_in users(:user_hacker)
    get :show, id: users(:user_plain)
    assert_redirected_to root_path
  end

  test "show logged in" do
    sign_in users(:user_plain)
    get :show, id: users(:user_plain)
    assert_response :success
  end

end
