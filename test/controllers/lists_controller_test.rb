require 'test_helper'

class ListsControllerTest < ActionController::TestCase
  setup do
    @list = lists(:list_1)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lists)
  end

end
