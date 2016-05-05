require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "name_and_email" do
    assert_equal "The Administrator &lt;admin@localhost&gt;", users(:user_admin).name_and_email
    assert_equal "oops &lt;haha&gt;", users(:user_hacker).name_and_email
  end

  test "email_and_name" do
    assert_equal "admin@localhost (The Administrator)", users(:user_admin).email_and_name
    assert_equal "haha (oops)", users(:user_hacker).email_and_name
  end

  test "subscribed_lists" do
    assert_equal [], users(:user_plain).subscribed_lists
    assert_equal [[lists(:list_1), "kind_subscriber"], [lists(:list_2), "kind_subscriber"], [lists(:list_3), "kind_watcher"]].sort, users(:user_list_subscriber).subscribed_lists.sort
  end

#  test "foo" do
#    assert_equal [talks(:talk_10), talks(:talk_11), talks(:talk_12),
#                  talks(:talk_13), talks(:talk_14), talks(:talk_15)].sort, lists(:list_1).talks.sort
#  end

  test "subscribed_talks" do
    assert_equal Hash.new, users(:user_plain).subscribed_talks(:all)
    h = {talks(:talk_10) => "kind_subscriber_through",
         talks(:talk_11) => "kind_subscriber_through",
         talks(:talk_12) => "kind_subscriber_through",
         talks(:talk_13) => "kind_subscriber_through",
         talks(:talk_14) => "kind_subscriber_through",
         talks(:talk_15) => "kind_subscriber_through",
         talks(:talk_30) => "kind_watcher_through",
         talks(:talk_31) => "kind_watcher_through",
         talks(:talk_32) => "kind_watcher_through",
         talks(:talk_minimal) => "kind_subscriber",
        }
    assert_equal h, users(:user_list_subscriber).subscribed_talks(:all)
  end
end
