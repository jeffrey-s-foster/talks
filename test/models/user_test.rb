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
  
  # test "the truth" do
  #   assert true
  # end
end
