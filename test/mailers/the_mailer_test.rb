require 'test_helper'

class TheMailerTest < ActionMailer::TestCase
  test "send talks" do
    
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

#  test "upcoming_talks" do
#    mail = Notifications.upcoming_talks
#    assert_equal "Upcoming talks", mail.subject
#    assert_equal ["to@example.org"], mail.to
#    assert_equal ["from@example.com"], mail.from
#    assert_match "Hi", mail.body.encoded
#  end

end
