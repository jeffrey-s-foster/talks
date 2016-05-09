require 'test_helper'

class ListsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:user_admin)
    @plain = users(:user_plain)
    @list_hash = {list: {
        name: "Test4298174",
        short_descr: "Test short descr",
        long_descr: "Test long descr"},
      owner_0: @admin.id,
      owner_proto: "",
      poster_0: @plain.id,
      poster_proto: ""
    }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lists)
  end

  test "show" do
    get :show, id: lists(:list_1).id
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
  end

  test "new admin" do
    sign_in users(:user_admin)
    get :new
    assert_response :success
  end

  test "create not logged in" do
    put :create, @list_hash
    assert_redirected_to root_path
    assert_nil (List.find_by name: "Test4298174")
  end

  test "create hacker" do
    sign_in users(:user_hacker)
    put :create, @list_hash
    assert_redirected_to root_path
    assert_nil (List.find_by name: "Test4298174")
  end

  test "create admin" do
    sign_in users(:user_admin)
    put :create, @list_hash
    l = List.find_by name: "Test4298174"
    assert_not_nil l
    assert_includes(l.owners, @admin)
    assert_includes(l.posters, @plain)
    assert_redirected_to list_path(l)
  end

  test "edit not logged in" do
    get :edit, id: lists(:list_owned).id
    assert_redirected_to root_path
  end

  test "edit hacker" do
    sign_in users(:user_hacker)
    get :edit, id: lists(:list_owned).id
    assert_redirected_to root_path
  end

  test "edit admin" do
    sign_in users(:user_admin)
    get :edit, id: lists(:list_owned).id
    assert_response :success
  end

  test "edit owner" do
    sign_in users(:user_talk_owner)
    get :edit, id: lists(:list_owned).id
    assert_response :success
  end

  test "update not logged in" do
    put :update, @list_hash.reverse_merge(id: lists(:list_owned).id)
    l = List.find(lists(:list_owned).id)
    assert_equal "List owned", l.name # user can't change name
    assert_not_includes(lists(:list_owned).owners, @admin)
    assert_not_includes(lists(:list_owned).posters, @plain)
    assert_redirected_to root_path
  end

  test "update hacker" do
    sign_in users(:user_hacker)
    put :update, @list_hash.reverse_merge(id: lists(:list_owned).id)
    l = List.find(lists(:list_owned).id)
    assert_equal "List owned", l.name # user can't change name
    assert_not_includes(lists(:list_owned).owners, @admin)
    assert_not_includes(lists(:list_owned).posters, @plain)
    assert_redirected_to root_path
  end

  test "update admin" do
    sign_in users(:user_admin)
    assert_not_includes(lists(:list_owned).owners, @admin)
    assert_not_includes(lists(:list_owned).posters, @plain)
    put :update, @list_hash.reverse_merge(id: lists(:list_owned).id)
    l = List.find(lists(:list_owned).id)
    assert_not_nil l
    assert_includes(l.owners, @admin)
    assert_includes(l.posters, @plain)
    assert_equal "Test4298174", l.name
    assert_redirected_to list_path(l)
  end

  test "update owner" do
    sign_in users(:user_talk_owner)
    assert_not_includes(lists(:list_owned).owners, @admin)
    assert_not_includes(lists(:list_owned).posters, @plain)
    put :update, @list_hash.reverse_merge(id: lists(:list_owned).id)
    l = List.find(lists(:list_owned).id)
    assert_not_nil l
    assert_includes(l.owners, @admin)
    assert_includes(l.posters, @plain)
    assert_equal "List owned", l.name # user can't change name
    assert_redirected_to list_path(l)
  end

  test "destroy not logged in" do
    id = lists(:list_owned).id
    delete :destroy, id: id
    assert_redirected_to root_path
    assert_not_nil List.find(id)
  end

  test "destroy hacker" do
    sign_in(:user_hacker)
    id = lists(:list_owned).id
    delete :destroy, id: id
    assert_redirected_to root_path
    assert_not_nil List.find(id)
  end

  test "destroy admin" do
    sign_in users(:user_admin)
    id = lists(:list_owned).id
    delete :destroy, id: id
    assert_redirected_to root_path
    assert_raises(ActiveRecord::RecordNotFound) { List.find(id) }
  end

  test "destroy owner" do
    sign_in users(:user_talk_owner)
    id = lists(:list_owned).id
    delete :destroy, id: id
    assert_redirected_to root_path
    assert_not_nil List.find(id) # only admin can delete list
  end

end
