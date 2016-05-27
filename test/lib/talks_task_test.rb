class TalksTaskTest < ActionMailer::TestCase
  # Inherits from ActionMailer::TestCase so mailings are reset

  test "send today" do
    ActionMailer::Base.deliveries = []
    u = users(:user_to_email)
    travel_to Time.parse("2016-05-08 12:30:00 UTC") do
      Rake::Task['talks:send_today'].invoke
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries[0]
    assert_equal [u.email], email.to
    assert_equal ["talks@cs.umd.edu"], email.from
    assert_match(/Subscribed Direct/, email.body.to_s)
    assert_match(/Subscribed Indirect/, email.body.to_s)
    assert_no_match(/Subscribed DTomorrow/, email.body.to_s)
    assert_no_match(/Subscribed ITomorrow/, email.body.to_s)
  end

  test "send this week" do
    ActionMailer::Base.deliveries = []
    u = users(:user_to_email)
    travel_to Time.parse("2016-05-08 12:30:00 UTC") do
      Rake::Task['talks:send_this_week'].invoke
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries[0]
    assert_equal [u.email], email.to
    assert_equal ["talks@cs.umd.edu"], email.from
    assert_match(/Subscribed Direct/, email.body.to_s)
    assert_match(/Subscribed Indirect/, email.body.to_s)
    assert_match(/Subscribed DTomorrow/, email.body.to_s)
    assert_match(/Subscribed ITomorrow/, email.body.to_s)
  end

end
