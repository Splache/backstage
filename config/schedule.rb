set :environment, :development

every 1.hour do
  rake "mailer:send_activity_report"
end
