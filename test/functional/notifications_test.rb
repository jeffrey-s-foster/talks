require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  test "upcoming_talks" do
    mail = Notifications.upcoming_talks
    assert_equal "Upcoming talks", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
