require 'test_helper'

class TalkTest < ActiveSupport::TestCase

  test "validations" do
    assert talks(:talk_11).valid?
    assert talks(:talk_minimal).valid?
    assert talks(:talk_start_end_different_days).invalid?
    assert talks(:talk_no_start).invalid?
    assert talks(:talk_no_end).invalid?
    assert talks(:talk_start_before_end).invalid?
    assert talks(:talk_no_owner).invalid?
    assert talks(:talk_no_list).invalid?
  end

  test "extended title" do
    assert_equal "Title 11", talks(:talk_11).extended_title
  end

  test "subscription" do
    assert_equal nil, talks(:talk_11).subscription(users(:user_plain))
    assert_equal subscriptions(:s_six), talks(:talk_minimal).subscription(users(:user_list_subscriber))
    assert_equal subscriptions(:s_seven), talks(:talk_no_start).subscription(users(:user_list_subscriber))
  end

  test "subscriber-watcher?" do
    assert_not talks(:talk_11).subscriber?(users(:user_plain))
    assert_not talks(:talk_11).watcher?(users(:user_plain))
    assert talks(:talk_minimal).subscriber?(users(:user_list_subscriber))
    assert_not talks(:talk_minimal).watcher?(users(:user_list_subscriber))
    assert_not talks(:talk_no_start).subscriber?(users(:user_list_subscriber))
    assert talks(:talk_no_start).watcher?(users(:user_list_subscriber))
    assert_not talks(:talk_11).subscriber?(users(:user_list_subscriber)) # not transitively through lists
    assert_not talks(:talk_31).watcher?(users(:user_list_subscriber)) # not transitively through lists
  end

  test "registered?" do
    assert_not talks(:talk_12).registered?(users(:user_plain))
    assert talks(:talk_10).registered?(users(:user_plain))
    assert_not talks(:talk_13).registered?(users(:user_plain))
  end
  
  # through(user)
  # email_watchers(changes)
  
end
