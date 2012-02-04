class Notifications < ActionMailer::Base
  # time_interval can be :today or :this_week
  def send_talks(user, talks, subj)
    @talks = talks.sort { |a,b| a.start_time <=> b.start_time }
    @subj = subj

    mail :to => "#{user.name} <#{user.email}>",
	:subject => "[talks] #{@subj}",
	:from => "Talks <jfoster@cs.umd.edu>"
  end

  def send_external_reg(reg)
    @reg = reg
    @talk = reg.talk

    mail :to => "#{@reg.name} <#{@reg.email}>",
         :subject => "[talks] Registration confirmation",
         :from => "Talks <jfoster@cs.umd.edu>"
  end
end
