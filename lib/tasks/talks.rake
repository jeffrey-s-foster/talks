namespace :talks  do

  desc "Send email to subscribers of today's talks"
  task :today => :environment do
    Rails.logger.debug "Sending..."
    Rails.logger.flush
    puts "#{Rails.inspect}"
    puts "Done"

  end

  desc "Send email to subscribers of this week's talks"
  task :this_week => :environment do
  end
end
