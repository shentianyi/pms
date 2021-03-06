# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
set :output, {:error => "#{path}/log/cron_error_log.log", :standard => "#{path}/log/cron_log.log"}
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
set :environment, :development
# Learn more: http://github.com/javan/whenever
# every :reboot do
#   rake 'sidekiq:start'
# end

every 1.day,:at=>['07:35','11:30','19:35'] do
  command "backup perform -t db_backup -c #{path}/config/backup/config.rb"
end

#clear log every month
every 1.month,:at=>['7:00'] do
  rake "log:clear"
end

#every 1.minute do
 #command 'sudo /opt/nginx/sbin/nginx -s reload'
#end
#every 1.minute do
#  rake "log:clear"
#end

