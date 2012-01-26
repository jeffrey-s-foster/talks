class Notifications < ActionMailer::Base
  # time_interval can be :today or :this_week
  def upcoming_talks(user, time_interval)
    case time_interval
    when :today
      @talks = user.subscribed_talks(true).to_a.map { |k,v| if (v == :kind_subscriber || v == :kind_subscriber_through) then k else nil end}.compact
      @subject = "Today's talks"
    when :this_week
      @talks = user.subscribed_talks(true)
      @subject = "This week's talks"
    else
      Rails.logger.error "Bad argument #{time_interval} to upcoming_talks"
      return
    end

    @talks.sort! { |a,b| a.start_time <=> b.start_time }

    mail :to => user.email,
	:subject => "[talks] #{@subject}",
	:from => "jfoster@cs.umd.edu"
  end
end
