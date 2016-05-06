require 'test_helper'

class BuildingsControllerTest < ActionController::TestCase
  setup do
    @avw = buildings(:avw)
    @csic = buildings(:csic)
    @user_plain = users(:user_plain)
    @user_admin = users(:user_admin)
  end

  test "not logged in" do
    get :index
    assert_redirected_to root_path
    patch :update, id:@avw, abbrv:"foo"
    assert_redirected_to root_path
    assert_equal "AVW", Building.find(buildings(:avw).id).abbrv
    delete :destroy, id:@avw
    assert_redirected_to root_path
    assert_equal @avw, Building.find(buildings(:avw).id)
  end

  test "logged in admin" do
    sign_in @user_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:buildings)
    assert_difference('Building.count', -1) do
      delete :destroy, id:@avw
    end
    assert_redirected_to buildings_index_path
    csic_abbrv_sym = "building_abbrv_#{@csic.id}".to_sym
    csic_name_sym = "building_name_#{@csic.id}".to_sym
    csic_url_sym = "building_url_#{@csic.id}".to_sym
    post :update, csic_abbrv_sym=>"WVA", csic_name_sym=>"W.V.A. Building", csic_url_sym=>"WVA URL"
    assert_redirected_to buildings_index_path
    tmp = Building.find_by abbrv: "WVA"
    assert_equal "W.V.A. Building", tmp.name
    assert_equal "WVA URL", tmp.url
    post :update, building_abbrv_new:"FOO", building_name_new:"The Foo Building", building_url_new:"Foo URL"
    assert_redirected_to buildings_index_path
    tmp = Building.find_by abbrv: "FOO"
    assert_equal "The Foo Building", tmp.name
    assert_equal "Foo URL", tmp.url
  end

  test "logged in as unprivileged user" do
    sign_in @user_plain
    get :index
    assert_redirected_to root_path
    patch :update, id:@avw, abbrv:"foo"
    assert_redirected_to root_path
    assert_equal "AVW", Building.find(buildings(:avw).id).abbrv
    delete :destroy, id:@avw
    assert_redirected_to root_path
    assert_equal @avw, Building.find(buildings(:avw).id)
  end
end
