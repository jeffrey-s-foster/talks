class Notifications < ActionMailer::Base
  # time_interval can be :today or :this_week
  def upcoming_talks(user, time_interval)
    mail
    to: user.email,
    subject: "Testing"
  end
end
