namespace :talks  do

  desc "Send email to subscribers of today's talks"
  task :today => :environment do
    Rails.logger.debug "Sending today's talks..."
    user = User.find(1)
    talks = user.subscribed_talks(:today, [:kind_subscriber, :kind_subscriber_through]).keys
    unless talks.empty?
      Notifications.send_talks(user, talks, "Today's talks").deliver
    else
      Rails.logger.debug "Skipping #{user.email} - empty talks"
    end
    Rails.logger.debug "Done sending"
  end

  desc "Send email to subscribers of this week's talks"
  task :this_week => :environment do
  end
end
