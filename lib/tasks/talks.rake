namespace :talks  do

  desc "Send email to subscribers of today's talks"
  task :today => :environment do
    Rails.logger.debug "Sending today's talks at #{Time.now}..."
    User.all do |user|
      talks = user.subscribed_talks(:today, [:kind_subscriber, :kind_subscriber_through]).keys
      next unless talks.opt_email_today
      unless talks.empty?
        Notifications.send_talks(user, talks, "Today's talks").deliver
      else
        Rails.logger.debug "Skipping #{user.email} - empty talks"
      end
    end
    Rails.logger.debug "Done sending at #{Time.now}"
  end

  desc "Send email to subscribers of this week's talks"
  task :this_week => :environment do
    Rails.logger.debug "Sending this weeky's talks at #{Time.now}..."
    User.all do |user|
      talks = user.subscribed_talks(:this_week, [:kind_subscriber, :kind_subscriber_through]).keys
      next unless talks.opt_email_this_week
      unless talks.empty?
        Notifications.send_talks(user, talks, "This week's talks").deliver
      else
        Rails.logger.debug "Skipping #{user.email} - empty talks"
      end
      Rails.logger.debug "Done sending at #{Time.now}"
    end
  end
end
