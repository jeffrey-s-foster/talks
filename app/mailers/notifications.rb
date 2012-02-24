class Notifications < ActionMailer::Base
  helper :application
  helper :talks

  # time_interval can be :today or :this_week
  def send_talks(user, talks, subj)
    @talks = talks.sort { |a,b| a.start_time <=> b.start_time }
    @subj = subj

    mail :to => "#{user.name} <#{user.email}>",
	:subject => "[Talks] #{@subj}",
	:from => "Talks <talks@cs.umd.edu>"
  end

  def send_external_reg(reg)
    @reg = reg
    @talk = reg.talk

    mail :to => "#{@reg.name} <#{@reg.email}>",
         :subject => "[Talks] Registration confirmation",
         :from => "Talks <talks@cs.umd.edu>"
  end

  def send_talk_change(user, talk, changes)
    @user = user
    @talk = talk
    @changes = changes
    if @changes
      @subj = "[Talks] Talk update: #{@talk.title}"
    else
      @subj = "[Talks] New talk posted: #{@talk.title}"
    end
    
    mail :to => "#{@user.name} <#{@user.email}>",
         :subject => @subj,
         :from => "Talks <talks@cs.umd.edu>"
  end

  def send_feedback(h)
    @comments = h[:comments]
    mail :to => "Talks <talks@cs.umd.edu>",
         :subject => h[:subject],
         :from => h[:email]
  end

end
