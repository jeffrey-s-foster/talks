require 'test_helper'

class TalksControllerTest < ActionController::TestCase

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

  test "create talk" do
    sign_in users(:user_admin)
    put :create, talk: {
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
      posted_proto: ""
    t = Talk.find_by_title("Test4298174")
    assert_not_nil t
    assert_redirected_to talk_path(t)
  end

end
