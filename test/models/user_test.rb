require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @admin = users(:admin)
    @user = users(:user)
    @user_no_email_today = users(:user_no_email_today)
    @user_no_email = users(:user_no_email)
    @hacker = users(:hacker)
  end

  test "name_and_email" do
    assert_equal "The Administrator &lt;admin@localhost&gt;", @admin.name_and_email
    assert_equal "oops &lt;haha&gt;", @hacker.name_and_email
  end

  test "email_and_name" do
    assert_equal "admin@localhost (The Administrator)", @admin.email_and_name
    assert_equal "haha (oops)", @hacker.email_and_name
  end
  
  # test "the truth" do
  #   assert true
  # end
end
