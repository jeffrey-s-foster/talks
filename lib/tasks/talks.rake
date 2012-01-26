namespace :talks  do

  desc "Send email to subscribers of today's talks"
  task :today => :environment do
    Rails.logger.debug "Sending today's talks..."
    u = User.find(1)
    Notifications.upcoming_talks(u, :today).deliver
    Rails.logger.debug "Done sending"
  end

  desc "Send email to subscribers of this week's talks"
  task :this_week => :environment do
  end
end
