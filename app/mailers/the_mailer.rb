class TheMailer < ApplicationMailer
  helper :application
  helper :talks

  def send_talks(user, talks, subj)
    @talks = talks.sort { |a,b| a.start_time <=> b.start_time }
    @subj = subj
    mail :to => "#{user.name} <#{user.email}>",
         :subject => "[Talks] #{@subj}"
  end

  def send_external_reg(reg)
    @reg = reg
    @talk = reg.talk

    mail :to => "#{@reg.name} <#{@reg.email}>",
         :subject => "[Talks] Registration confirmation"
  end

  def send_cancel_reg(reg)
    @reg = reg
    @talk = reg.talk

    mail :to => "#{@reg.name} <#{@reg.email}>",
         :subject => "[Talks] Registration cancellation"
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
         :subject => @subj
  end

  def send_feedback(h)
    @comments = h[:comments]
    mail :to => "Talks <talks@cs.umd.edu>",
         :subject => h[:subject],
         :from => "#{h[:name]} <#{h[:email]}>"
  end

  def send_admin_message(u, h)
    @message = h[:message]
    mail :to => "#{u.name} <#{u.email}>",
         :subject => h[:subject]
  end

end
