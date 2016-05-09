require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user_update_hash = {
      name: "Updated name",
      email: "updated-email@example.com",
      organization: "Updated organization",
      password: "new password",
      password_confirmation: "new password",
      opt_email_today: false,
      opt_email_this_week: false
    }
    @user_update_no_password = {
      name: "Updated name",
      email: "updated-email@example.com",
      organization: "Updated organization",
      password: "",
      password_confirmation: "",
      opt_email_today: false,
      opt_email_this_week: false
    }
    @user_update_hacker_hash = {
      name: "Updated name",
      email: "updated-email@example.com",
      organization: "Updated organization",
      password: "new password",
      password_confirmation: "new password",
      opt_email_today: false,
      opt_email_this_week: false,
      perm_site_admin: true,
      perm_create_talk: true
    }
  end

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

  test "update user admin" do
    sign_in users(:user_admin)
    old = User.find(users(:user_plain).id)
    put :update, id: old, user: @user_update_hash
    assert_redirected_to user_path(users(:user_plain))
    u = User.find(old.id)
    assert_equal @user_update_hash[:name], u.name
    assert_equal @user_update_hash[:email], u.unconfirmed_email
    assert_equal @user_update_hash[:organization], u.organization
    assert_not_equal old.encrypted_password, u.encrypted_password
    assert_equal @user_update_hash[:opt_email_today], u.opt_email_today
    assert_equal @user_update_hash[:opt_email_this_week], u.opt_email_this_week
  end

  test "update user user" do
    sign_in users(:user_plain)
    old = User.find(users(:user_plain).id)
    put :update, id: old, user: @user_update_hash
    assert_redirected_to user_path(users(:user_plain))
    u = User.find(old.id)
    assert_equal @user_update_hash[:name], u.name
    assert_equal @user_update_hash[:email], u.unconfirmed_email
    assert_equal @user_update_hash[:organization], u.organization
    assert_not_equal old.encrypted_password, u.encrypted_password
    assert_equal @user_update_hash[:opt_email_today], u.opt_email_today
    assert_equal @user_update_hash[:opt_email_this_week], u.opt_email_this_week
  end

  test "update user no password" do
    sign_in users(:user_plain)
    old = User.find(users(:user_plain).id)
    put :update, id: old, user: @user_update_no_password
    assert_redirected_to user_path(users(:user_plain))
    u = User.find(old.id)
    assert_equal old.encrypted_password, u.encrypted_password
  end

  test "update hacker" do
    sign_in users(:user_hacker)
    old = User.find(users(:user_hacker).id)
    put :update, id: old, user: @user_update_hacker_hash
    assert_redirected_to user_path(users(:user_hacker))
    u = User.find(old.id)
    assert_not u.perm_site_admin
    assert_not u.perm_create_talk
  end

  test "update hacker admin" do
    sign_in users(:user_admin)
    old = User.find(users(:user_hacker).id)
    put :update, id: old, user: @user_update_hacker_hash
    assert_redirected_to user_path(users(:user_hacker))
    u = User.find(old.id)
    assert u.perm_site_admin
    assert u.perm_create_talk
  end

  test "destroy not logged in" do
    id = users(:user_plain).id
    delete :destroy, id: id
    assert_redirected_to root_path
    assert_not_nil User.find(id)
  end

  test "destroy logged in" do
    sign_in(:user_plain)
    id = users(:user_plain).id
    delete :destroy, id: id
    assert_redirected_to root_path
    assert_not_nil User.find(id)
  end

  test "destroy admin" do
    sign_in users(:user_admin)
    id = users(:user_plain).id
    delete :destroy, id: id
    assert_redirected_to users_path
    assert_raises(ActiveRecord::RecordNotFound) { User.find(id) }
  end

  test "feed" do
    u = users(:user_plain)
    get :feed, id: u, key: u.ical_secret, format: :atom
    assert_response :success
    get :feed, id: u, key: u.ical_secret, format: :ics
    assert_response :success
    get :feed, id: u, key: 0, format: :atom
    assert_response :forbidden
    get :feed, id: u, key: 0, format: :ics
    assert_response :forbidden
  end

  test "reset_ical_secret logged in" do
    sign_in users(:user_plain)
    u = users(:user_plain)
    assert_equal "12345", u.ical_secret
    get :reset_ical_secret, id: u
    assert_redirected_to users_path
    assert_nil User.find(u.id).ical_secret
  end

  test "reset_ical_secret admin" do
    sign_in users(:user_admin)
    u = users(:user_plain)
    sign_in u
    assert_equal "12345", u.ical_secret
    get :reset_ical_secret, id: u
    assert_redirected_to users_path
    assert_nil User.find(u.id).ical_secret
  end

  test "reset_ical_secret hacker" do
    sign_in users(:user_hacker)
    u = users(:user_plain)
    get :reset_ical_secret, id: u
    assert_redirected_to root_path
    assert_not_nil User.find(u.id).ical_secret
  end

end
