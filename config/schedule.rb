# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

every :sunday, :at => "12:30am" do
  rake "talks:send_this_week"
end

every 1.day, :at => "12:30am" do
  rake "talks:send_today"
end

every 1.day, :at => "12:30am"  do
  command "backup perform --trigger talks_backup --root-path #{File.expand_path("../../Backup", __FILE__)}"
end

# Learn more: http://github.com/javan/whenever
