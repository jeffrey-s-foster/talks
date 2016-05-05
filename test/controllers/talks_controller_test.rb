require 'test_helper'

class TalksControllerTest < ActionController::TestCase

  def setup
    @talk_hash = {talk: {
        title: "Test4298174",
        speaker: "Someone",
        speaker_affiliation: "Affiliation",
        speaker_url: "URL",
        room: "123",
        building_id: buildings(:avw),
        kind: "standard",
        request_reg: 0,
        trigger_watch_email: 0,
        owner_id: users(:user_admin),
        abstract: "The abstract",
        bio: "The bio",
        reg_info: "No reg info"
      },
      temp_date_time: "tomorrow from 10am to 11am",
      temp_date: "",
      temp_start_time: "",
      temp_end_time: "",
      posted_0: lists(:list_1),
      posted_proto: ""}
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "admin view not logged in" do
    get :admin_view
    assert_redirected_to root_path
  end

  test "admin view hacker" do
    sign_in users(:user_hacker)
    get :admin_view
    assert_redirected_to root_path
  end

  test "admin view admin" do
    sign_in users(:user_admin)
    get :admin_view
    assert_response :success
  end

  test "should show" do
    get :show, id: talks(:talk_11).id
    assert_response :success
  end

  test "new not logged in" do
    get :new
    assert_redirected_to root_path
  end

  test "new hacker" do
    sign_in users(:user_hacker)
    get :new
    assert_redirected_to root_path
    sign_out users(:user_hacker)
  end

  test "new admin" do
    sign_in users(:user_admin)
    get :new
    assert_response :success
  end

  test "create not logged in" do
    put :create, @talk_hash
    assert_redirected_to root_path
  end

  test "create hacker" do
    sign_in users(:user_hacker)
    put :create, @talk_hash
    assert_redirected_to root_path
  end

  test "create admin" do
    sign_in users(:user_admin)
    put :create, @talk_hash
    t = Talk.find_by title: "Test4298174"
    assert_not_nil t
    assert_redirected_to talk_path(t)
  end

end
