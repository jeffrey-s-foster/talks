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
      posted_proto: ""
    }
    @talk_update_hash = {talk: {
        title: "Test4298174",
        speaker: "The Speaker",
        speaker_affiliation: "The Affiliation",
        speaker_url: "http://www.cs.umd.edu",
        room: "1115",
        building_id: buildings(:csic),
        kind: "standard",
        request_reg: 0,
        trigger_watch_email: 0,
        owner_id: users(:user_talk_owner),
        abstract: "The Abstract",
        bio: "The Bio",
        reg_info: ""
      },
      temp_date_time: "",
      temp_date: "",
      temp_start_time: "2015-01-01 10:00:00 -0500",
      temp_end_time: "2015-01-01 11:00:00 -0500",
      posted_0: lists(:list_owned),
      posted_proto: ""
    }
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
    assert_nil (Talk.find_by title: "Test4298174")
  end

  test "create hacker" do
    sign_in users(:user_hacker)
    put :create, @talk_hash
    assert_redirected_to root_path
    assert_nil (Talk.find_by title: "Test4298174")
  end

  test "create admin" do
    sign_in users(:user_admin)
    put :create, @talk_hash
    t = Talk.find_by title: "Test4298174"
    assert_not_nil t
    assert_redirected_to talk_path(t)
  end

  test "edit not logged in" do
    get :edit, id: talks(:talk_owned).id
    assert_redirected_to root_path
  end

  test "edit hacker" do
    sign_in users(:user_hacker)
    get :edit, id: talks(:talk_owned).id
    assert_redirected_to root_path
  end

  test "edit admin" do
    sign_in users(:user_admin)
    get :edit, id: talks(:talk_owned).id
    assert_response :success
  end

  test "edit owner" do
    sign_in users(:user_talk_owner)
    get :edit, id: talks(:talk_owned).id
    assert_response :success
  end

  test "update not logged in" do
    put :update, @talk_hash.reverse_merge(id: talks(:talk_owned).id)
    assert_redirected_to root_path
    assert_equal "Owned", talks(:talk_owned).title
  end

  test "update hacker" do
    sign_in users(:user_hacker)
    put :update, @talk_hash.reverse_merge(id: talks(:talk_owned).id)
    assert_redirected_to root_path
    assert_equal "Owned", talks(:talk_owned).title
  end

  test "update admin" do
    sign_in users(:user_admin)
    put :update, @talk_update_hash.reverse_merge(id: talks(:talk_owned).id)
    assert_redirected_to talk_path(talks(:talk_owned))
    assert_equal "Test4298174", Talk.find(talks(:talk_owned).id).title
  end

  test "update owner" do
    sign_in users(:user_talk_owner)
    put :update, @talk_update_hash.reverse_merge(id: talks(:talk_owned).id)
    assert_redirected_to talk_path(talks(:talk_owned))
    assert_equal "Test4298174", Talk.find(talks(:talk_owned).id).title
  end

  test "destroy not logged in" do
    id = talks(:talk_owned).id
    delete :destroy, id: id
    assert_redirected_to root_path
    assert_not_nil Talk.find(id)
  end

  test "destroy hacker" do
    sign_in(:user_hacker)
    id = talks(:talk_owned).id
    delete :destroy, id: id
    assert_redirected_to root_path
    assert_not_nil Talk.find(id)
  end

  test "destroy admin" do
    sign_in users(:user_admin)
    id = talks(:talk_owned).id
    delete :destroy, id: id
    assert_redirected_to talks_path
    assert_raises(ActiveRecord::RecordNotFound) { Talk.find(id) }
  end

  test "destroy owner" do
    sign_in users(:user_talk_owner)
    id = talks(:talk_owned).id
    delete :destroy, id: id
    assert_redirected_to talks_path
    assert_raises(ActiveRecord::RecordNotFound) { Talk.find(id) }
  end
end
