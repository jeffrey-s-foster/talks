require 'test_helper'

class TheMailerTest < ActionMailer::TestCase
  test "send talks" do
    u = users(:user_talk_owner)
    t = u.subscribed_talks(:all)
    m = "The message"
    email = TheMailer.send_talks(u, t, m).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [u.email], email.to
  end

  test "send reg" do
    r = registrations(:r_three)
    email = TheMailer.send_external_reg(r).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [r.email], email.to
  end

  test "send cancel reg" do
    r = registrations(:r_three)
    email = TheMailer.send_cancel_reg(r).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [r.email], email.to
  end

  test "send new" do
    u = users(:user_talk_owner)
    t = talks(:talk_owned)
    email = TheMailer.send_talk_change(u, t, nil).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [u.email], email.to
  end

  test "send update" do
    u = users(:user_talk_owner)
    t = talks(:talk_owned)
    changes = Set.new [:title]
    email = TheMailer.send_talk_change(u, t, changes).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [u.email], email.to
  end

  test "send feedback" do
    email = TheMailer.send_feedback(subject: "Feedback", name: "me",
      email: "me@me.com", comments: "My comments").deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["talks@cs.umd.edu"], email.to
    assert_equal "Feedback", email.subject
    assert_equal ["me@me.com"], email.from
  end

  test "send admin message" do
    u = users(:user_plain)
    email = TheMailer.send_admin_message(u, subject: "Subject",
      message: "Message").deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [u.email], email.to
    assert_equal "Subject", email.subject
  end

end
