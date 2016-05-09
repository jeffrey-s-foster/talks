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

  test "edit not logged in" do
    get :edit, id: users(:user_plain)
    assert_redirected_to root_path
  end

  test "edit hacker" do
    get :edit, id: users(:user_plain)
    assert_redirected_to root_path
  end

  test "edit admin" do
    sign_in users(:user_admin)
    get :edit, id: users(:user_plain)
    assert_response :success
  end

  test "edit user" do
    sign_in users(:user_plain)
    get :edit, id: users(:user_plain)
    assert_response :success
  end

end
