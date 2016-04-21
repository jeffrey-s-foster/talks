require 'test_helper'

class BuildingsControllerTest < ActionController::TestCase
  setup do
    @avw = buildings(:avw)
    @user_admin = users(:user_admin)
  end

  test "not logged in" do
    get :index
    assert_redirected_to root_path
    patch :update, id:@avw, abbrv:"foo"
    assert_redirected_to root_path
    assert_equal "AVW", buildings(:avw).abbrv
    delete :destroy, id:@avw
    assert_redirected_to root_path
    assert_equal @avw, buildings(:avw)
  end

  test "logged in admin" do
    sign_in @user_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:buildings)
    assert_difference('Building.count', -1) do
      delete :destroy, id:@avw
    end
#    assert_response :success
    #    post :update, id:@avw, abbrv:"WVA"
    #    assert_response :success
    #    assert_equal "WVA", buildings(:avw).abbrv
  end
end
