class Notifications < ActionMailer::Base
  # time_interval can be :today or :this_week
  def send_talks(user, talks, subj)
    @talks = talks.sort { |a,b| a.start_time <=> b.start_time }
    @subject = subj

    mail :to => "#{user.name} <#{user.email}>",
	:subject => "[talks] #{@subject}",
	:from => "Talks <jfoster@cs.umd.edu>"
  end
end
