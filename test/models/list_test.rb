require 'test_helper'

class ListTest < ActiveSupport::TestCase
  test "subscription" do
    assert_equal nil, lists(:list_1).subscription(users(:user_plain))
    assert_equal subscriptions(:s_one), lists(:list_1).subscription(users(:user_list_subscriber))
    assert_equal subscriptions(:s_three), lists(:list_3).subscription(users(:user_list_subscriber))
  end
  
end
